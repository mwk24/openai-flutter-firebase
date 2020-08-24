const functions = require('firebase-functions');

// The Firebase Admin SDK to access Cloud Firestore.
const admin = require('firebase-admin');
admin.initializeApp();

// OPENAI
const OpenAI = require('openai-api');
const { database } = require('firebase-admin');
const OPEN_AI_API_KEY = 'XXX';
const openai = new OpenAI(OPEN_AI_API_KEY);

exports.onMessageCreate = functions.firestore.document("conversations/{conversationID}/messages/{messageID}")
    .onCreate(async (snap, context) => {
        
      // Grab the current value of what was written to Cloud Firestore.
      const data = snap.data();

      if (data['author'] == 'AI') {
          console.log('Message is from AI, do not ask for completion');
          return;
      }

      // Fetch the prompt
      const settings = await admin.firestore().doc("settings/openai_config").get();
      const preamble = settings.data()['preamble'];
      
      var conversation = '';
      const allMessages = await admin.firestore().collection(snap.ref.parent.path).orderBy('created').get();
      allMessages.forEach(doc => {
          conversation += ('\n' + doc.data()['author'] + ': ' + doc.data()['msg']);
      })

      const gptResponse =  await requestFromOpenAI(preamble + conversation);
      var date = new Date()

      return snap.ref.parent.add(          
        {   
            author: 'AI',
            preamble: preamble,
            conversation: conversation,
            raw:  gptResponse.data,
            msg: gptResponse.data.choices[0].text,
           // created_server: admin.database.ServerValue.TIMESTAMP,
            created: date
         });
    });


function requestFromOpenAI(prompt) {
    return openai.complete({
        engine: 'davinci',
        prompt: prompt + '\n AI: ',
        maxTokens: 512,
        temperature: 0.8,
        topP: 1,
        n: 1,
        stream: false,
        stop: ['\n', "testing", "Human:", "AI:"]
    });
}