class Wlossdrinks {
  String image;
  String name;
  String desc;
  String nfact;
  String benefits;
  String side_effects;
  Wlossdrinks(
      {required this.image,
      required this.name,
      required this.desc,
      required this.nfact,
      required this.benefits,
      required this.side_effects});
}

List<Wlossdrinks> WLDrinksList = [
  Wlossdrinks(
      image: '',
      name: 'Water',
      desc: 'Water has more qualities that make it extremely useful for weight loss because of zero calories.\n\n',
      nfact: 'Nutritional facts:\nCalories: 0 \n Fat: 0g \n Sodium: 9.5mg \n Carbohydrates: 0g \n Fiber: 0g \n Sugars: 0g \n Protein: 0g\n\n',
      benefits: 'Health Benefit: \n Helps Maximize Physical Performance. \n Significantly affects energy Level and Brain Functions. \n May Help Prevent and Treat Headache. \n May Help relieve constipation. \n May Help treat kidney stone. \n Helps prevent Hangovers.\n\n',
      side_effects: 'Having too much is dangerous: \n Drinking too much water can be unhealthy and even lead to death in extreme cases. \n When you drink more water than your Kidneys can handle, you can upset the balance of sodium levels in your blood. \n This is called water intoxication and in extreme cases, it can cause brain damage, comas, and even death.'),
  Wlossdrinks(
      image: '',
      name: 'Green Tea:',
      desc: '',
      nfact: 'Nutritional facts:\n Calories: 0g. \n Total carbs:0.1g \n Net carbs:0.1g \n Fat: 0g \n Protein: 0g\n\n',
      benefits: 'Health benefits: \n Green tea and caffeine have a role in increasing energy metabolism, which lead to weight loss. \n Caffeine is a stimulant known to increase calorie expenditure and to improve performance during exercise. A cup of green tea contains 24-40 mg of caffeine. \n Green tea also contains a powerful antioxidant called epigallocatechin gallate another metabolism booster which can help break down excess fat in the body. Lower cholesterol.Reduces stroke risk.Type 2 diabetes.Alzheimer’s disease.',
      side_effects: 'Having too much is dangerous: \n Caffeine sensitivity. \n Liver damage. \n Other stimulants.'
      ),
  Wlossdrinks(
      image: '',
      name: 'Ginger tea:',
      desc: 'Ginger has antioxidants and anti-inflammatory properties that can help prevent cardiovascular damage and other stressors. ',
      nfact: 'Nutritional facts: 1 cup \n Calories: 19 \n Protein: 0 grams \n Fat: 0 grams \n Carbohydrates: 4 grams \n Fiber: 0 grams \n Sugar: 0 grams',
      benefits: 'Health benefits: \n Weight and blood sugar control. \n Immune support and cancer prevention. \n Small doses of ginger may relieve gastrointestinal irritation.',
      side_effects: ''),
  Wlossdrinks(
      image: '',
      name: 'Watermelon juice:',
      desc: 'There are 30 calories in 100 grams of Watermelon Juice.',
      nfact: 'Nutritional facts: Calories 30g \n Fat 0.15g \n Carbs 7.6g \n Protein: 0.61g',
      benefits: 'Health benefits: In addition, after 4 weeks, those who ate watermelon had:\n higher levels of antioxidants in their blood \n lower body weight and body mass index (BMI) \n lower systolic blood pressure \n improved waist-to-hip ratio ',
      side_effects: 'Having too much is dangerous:\n May raise your blood sugar levels'),
  Wlossdrinks(
      image: '',
      name: 'Pomegranate juice:',
      desc: 'Pomegranates are rich in antioxidants, polyphenols and conjugated linolenic acid - all of which help you burn fat and boost your metabolism.',
      nfact: 'One fresh pomegranate contains: \n Calories: 234 \n Protein: 5 grams \n Fat: 3 grams \n Carbohydrates: 53 grams \n Fiber: 11 grams \n Sugar: 39 grams \n Sodium: 8 grams',
      benefits: 'Health benefits: \n eating one pomegranate gives you about 28 mg of vitamin C, which is almost 50 percent of your Daily Recommended Intake (DRI). \n Rich Antioxidant \n Anti-inflammatory Properties \n ',
      side_effects: 'May lower blood pressure way too much(Avoid if you are suffering from Low Blood Pressure'),
];
