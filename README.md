# sequence

This project is an attempt to create 2 player sequence mobile game 

- Some Screenshots in sequence_game_screenshots folder

## Design

 This project makes use of the following :
 
 - Firestore And Firebase realtime Database for tracking user joins and left , used cards in deck , current player panel cards , player token placed , number of sequences created , tracking player turns and game result.
 - Firebase phone Authentication for authentication users on first login
 - Different Flutter features for rendering data on the app
 
 ## App Features

- Players take turns in placing tokens on board which is reflected immediately to other player and so the game continues on.
 - Saves game state to be resumed later like used cards in deck , current player panel cards , player token placed , number of sequences  created , tracking player turns and game result in case user disconnects.
 
 ## Upcoming App Features
 
 - Will use Firebase Cloud Messaging for notifications when new game is created or player disconnects.
 - Will use Wifi P2P to exchange data instead of Firebase incase internet is not available (like playing on an airplane).
 - App will switch automatically to Wifi P2P mode of communication when internet connection is not there.
 
