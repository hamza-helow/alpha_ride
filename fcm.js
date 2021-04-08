'use strict';

const functions = require('firebase-functions');

const admin = require('firebase-admin');

admin.initializeApp();


exports.sendNotification = functions.database.ref('/UsersNotification/{receiver}/{sender}')

    .onWrite(async (change, context) => {

      const receiver = context.params.receiver;

      const sender = context.params.sender;

      // If un-follow we exit the function.

      if (!change.after.val()) {

        return console.log('receiver : ', receiver, 'from :', sender);

      }
	  
	  
	  
	  const idNotification =  change.after.val();


  //  console.log('id Notification :  ' , idNotification );
      
      const getDeviceTokensPromise = admin.database()

      .ref(`/TokensDevices/${receiver}/`).once('value');


      const ref = admin.database().ref(`Notification/${idNotification}`).once('value');



      // The snapshot to the user's tokens.

      let tokensSnapshot;

      // The array containing all the user's tokens.

      let tokens;



      const results = await Promise.all([getDeviceTokensPromise, ref]);

      tokensSnapshot = results[0];

      const dataMessage = results[1];

      // Check if there are any device tokens.

      if (!tokensSnapshot.hasChildren()) {

        return console.log('There are no notification tokens to send to.');

      }

      console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.');



	   
     const idSender = sender; 
     
     console.log('idSender ', idSender );
       
     const Title = dataMessage.val().title; 

     console.log('messageText ', title );

     const content  = dataMessage.val().body ; 


      // Notification details.

      const payload = {

        notification: {

          title :Title ,

          body :content 
         

        }

      };



      // Listing all tokens as an array.

      tokens = Object.keys(tokensSnapshot.val());

      // Send notifications to all tokens.

      const response = await admin.messaging().sendToDevice(tokens, payload);

      // For each message check if there was an error.

      const tokensToRemove = [];

      response.results.forEach((result, index) => {

        const error = result.error;

        if (error) {

          console.error('Failure sending notification to', tokens[index], error);

          // Cleanup the tokens who are not registered anymore.

          if (error.code === 'messaging/invalid-registration-token' ||

              error.code === 'messaging/registration-token-not-registered') {

            tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());

          }

        }

      });

      return Promise.all(tokensToRemove);

    });