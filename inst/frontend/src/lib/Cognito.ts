import { Amplify } from 'aws-amplify';

Amplify.configure({
    Auth: {
        Cognito: {
            userPoolId: import.meta.env.VITE_APP_COGNITO_USER_POOL_ID,
            userPoolClientId: import.meta.env.VITE_APP_COGNITO_CLIENT_ID,
          }
        }
    }
);