# SafeGO

SafeGO provides a service to query high-risk road sections in advance. Users can enter their itinerary in advance before departure, and this app will inform them of which dangerous road sections they will pass through, the causes of accidents on those sections, relevant statistical information, and provide safer route options to avoid dangerous sections. While traveling, the app will use the user's GPS location. When the user approaches a dangerous road section within 300 meters, the system will notify the user in real-time through voice prompts, reminding them to pay attention to road safety, in the hope of reducing road accidents.

## How to Run

1. Install dependencies:

```
flutter pub get
```


2. Run the program:

```
flutter run
```

To run on a specific device, execute `flutter run -d <deviceID>`

* The deviceID can be obtained by running `flutter devices`.
