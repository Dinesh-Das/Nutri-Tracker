
class OnboardingContent{
  String image,title,description;
  OnboardingContent({required this.image, required this.title, required this.description});
}
List<OnboardingContent> contents = [
  OnboardingContent(
    title: 'Onboarding Page 1',
    image: 'assets/onboard/1.svg',
    description: "Description of onboarding Page 1"
  ),
  OnboardingContent(
    title: 'Onboarding Page 2',
    image: 'assets/onboard/2.svg',
    description: "Description of onboarding Page 2"
  ),
  OnboardingContent(
    title: 'Onboarding Page 3',
    image: 'assets/onboard/3.svg',
    description: "Description of onboarding Page 3"
  ),
  OnboardingContent(
    title: 'Onboarding Page 4',
    image: 'assets/onboard/4.svg',
    description: "Description of onboarding Page 4"
  ),
];