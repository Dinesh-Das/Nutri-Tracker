package com.example.nutri_tracker

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class NutriWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val totalCalories = widgetData.getInt("widget_total_calories", 0)
            val dailyGoal = widgetData.getInt("widget_daily_goal", 2000)
            val remainingCalories = widgetData.getInt(
                "widget_remaining_calories",
                dailyGoal - totalCalories
            )
            val lastMeal = widgetData.getString("widget_last_meal", null)
                ?: "Log a meal to update"
            val updatedAt = widgetData.getString("widget_updated_at", null)
                ?: "Open NutriTrack"

            val views = RemoteViews(context.packageName, R.layout.nutri_widget).apply {
                val launchIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.widget_container, launchIntent)
                setTextViewText(R.id.widget_calories, "$totalCalories / $dailyGoal kcal")
                setTextViewText(
                    R.id.widget_remaining,
                    "$remainingCalories kcal remaining"
                )
                setTextViewText(R.id.widget_last_meal, "Last: $lastMeal")
                setTextViewText(R.id.widget_updated_at, updatedAt)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
