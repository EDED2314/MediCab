## Inspiration 🤔💭
Many people in America suffer from overdose and other medical abuse scenarios because of an accident (over 100,000 people die every year due to it, and its a leading cause in death). This accident can be taking *more than* the required pills per day, taking the *wrong* pills for the wrong medication, or simply buying the wrong medicine. This is why we created MediCab. A comprehensive AI medicine manager/virtual cabinet that simplifies medicine tracking and provides medical assistance at your fingertips. 

## What it does 🗄️💊
MediCab is a full-stack application that serves as your personal AI medicine manager. The app allows you to log medicines and treatments into your virtual cabinet by simply taking photos. You can also update, remove, and query medicines in your list. The built-in chatbot utilizes the information from your virtual cabinet to diagnose possible illnesses based on your input symptoms. Moreover, MediCab assists you in correctly using medicines, provides details like physical medicine locations, standard market prices, and expiration dates, and even recommends additives/supplements for your healthcare plans.

## How we built it 🛠️🐍🐦
The app was developed using the Flutter framework for the frontend, while the backend utilized Python, Flask, and TensorFlow. The TensorFlow AI model enables effective detection of medicines from images, allowing users to manage their virtual cabinet efficiently by adding medicines in a snap of a photo. (Moreover, because of the lower attention spans born with many Gen-Z people, there is an increasing need to complete tasks (such as filling out forms for medicine logs) very quickly and accurtely.)

## Challenges we ran into 😵🧱
During development, several challenges were encountered and successfully addressed. Initially, the AI model suffered from overfitting and incorrectly recognized objects as bottles of hydrogen peroxide. However, through careful observation and adjustments, the model was refined to effectively detect medicines. 

More specifically, there were A LOT of problems when we were trying to train the AI. It took us at least 4 hours of back and forth debugging and checking to successfully train and *export* our **object detection** model. (which included moving the model from one machine to another and switching between windows and linux)

Next, another notable issue we ran into was that our backend had poor code and poor data handling (an example is that we did str(json map) rather than json.dumps(jsonmap) lol). This made us rewrite the entire backend from scratch again.

Second, another problem that we faced was collboration in the cloud. Some stuff (like api end points etc) were rly difficult to sort out virtually (such as my phone (app) needing to connect to an endpoint hosted by Etaash) so we had to meet up and code together for a limited amount of time.

Lastly, there were a lot of frontend problems that were one-by-one solved, a notable one was the AI chat bot integration and data handling logic.

## Accomplishments that we're proud of 💪😊
Sidenote: we actually started the brain storming and project coding (include ALLLL the files and stuff) ~12 hours after the hackathon started which meant we were on a massive time crunch.

```go
//TDLR;
fmt.Println("- AI model in time crunch")
fmt.Println("- UI and UX minor design features")
fmt.Println("- This project can really help people in need")

```

One accomplishment that both of us are proud about is our AI model's successful detection of medicines and creating a polished user experience were major accomplishments.

Another accomplishment that Eddie is proud of is *MANY* minor details put into the UI and UX of the app (even if its a hackathon project). All of the minor tweaks and improvements make the experience and UI of the app extra clean and tidy, which means the user will be happy.

## What we learned 😎📝
- Be careful with how the models are fit and carefully observe the learning process to determine if the model is overfit.  
- Use a better database from the start (such as mongodb)  
- Superb coordination is important for efficent development. 
- not use `str(dictionary)` but to use `json.dumps(dictionary)`
- sometimes linux > windows

## What's next for MediCab ✈️🌎
We have exciting plans for the future of MediCab:

- Integration of a better database system like MongoDB for enhanced performance and scalability.
- Expanding the AI model to include more medicines and improve accuracy.
- Implementing automatic dosage determination to assist users in their medication schedule.
- Strengthening the app's security and privacy features to ensure user data protection.

Furthermore, we envision adding features like medicine tracking, family profiles, and user profiles, making MediCab an indispensable tool for personalized healthcare management.
