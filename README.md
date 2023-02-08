![banner](https://user-images.githubusercontent.com/81645040/207942918-19d81b1d-c89e-4d22-a809-eb79807b3059.png)

# All Eat
A Food delivery app

## About the project
All Eat is a food delivery app developed as part of the A-Level OCR course. Development started from March 2022 to February 2023 with many iterations being completed. (Check https://github.com/IlyaSulli/AllEat/releases for the latest update). Although the app was never developed for the general market, it was designed to have the potential to have little work needed in order to get it on app stores. The app uses Flutter (using Dart) to build an Android application and was developed by a single developer.

## Common Issues
- **The app fails to login/create an account** - It is likely that by the time you try to use the app the servers have been pulled down but if you want to have it working, you can use the code from the final code to save a copy to a server and edit the code to go to your URL instead of the previous URLs
- **No restaurants are appearing** - Since the app was designed to be a standalone app and not rely on other food delivery apps, the database of restaurants was made as an example, having only 10 restaurants made for the Berkhamsted, England area. The app only shows restaurants that deliver to the destination. If you wish to see the restaurants, move your delivery destination to Berkhamsted on the map.
- **Can I trust this app?** - While the app is not malicious, it is recommended that you do not enter any valid information like a password you use or a valid email address. Never enter any valid payment cards into the app as other than the password, it is unencrypted and uses HTTP not HTTPS. For more information: [Click Here](https://www.cloudflare.com/en-gb/learning/ssl/why-is-http-not-secure/)

## Building the Source Code
If you wish to build the code for yourself, you will need to have your own API Key for the google maps functionality. Go to https://mapsplatform.google.com/ and get an API key. Then go to android/app/src/main and edit the AndroidManifest.xml.bak to be AndroidManifest.xml and replace the API KEY HERE to be the API Key.

## Documentation

Pre-prototype & Prototype 1A: https://docs.google.com/document/d/1qSwBISs3bfNNDpBvJHmaDCh-OqqwEP4sYRr-8F5wsAU/edit

Prototype 1B: https://docs.google.com/document/d/1somHT_j4UgcCpapECmO0GAGShc6dlx7MeBySGX69sIg/edit

Prototype 2: https://docs.google.com/document/d/1hzStvex3392VNqWgk1splfH5_jMYp9-h-LUl9WkYxuc/edit

Prototype 3: https://docs.google.com/document/d/1qbCiSld-ubUC7P6fJnEctjfQqLSKKBqsXGeqrCcA8-4/edit

Final Code: *COMING SOON*

## Credits

Images: Unsplash
