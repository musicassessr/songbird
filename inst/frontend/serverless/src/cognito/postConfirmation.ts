import postgres from 'postgres';
import { CognitoIdentityProviderClient, AdminUpdateUserAttributesCommand } from "@aws-sdk/client-cognito-identity-provider";



const sql = postgres({
    host: process.env.MUSICASSESSR_DB_HOST,
    port: 5432,
    database: process.env.MUSICASSESSR_DB_NAME,
    username: process.env.MUSICASSESSR_DB_USER,
    password: process.env.MUSICASSESSR_DB_PASSWORD,
    ssl: { rejectUnauthorized: false }
});

const client = new CognitoIdentityProviderClient();
const isEnabled = true

export const handler = async (event) => {

    try {
        const email = event.request.userAttributes.email ?? ""
        let result;
        if (email) {
            result = await sql`insert into users
            (username, enabled, email)
          values
            (${event.userName}, ${isEnabled}, ${email})  returning user_id`;
        }else {
          result = await sql`insert into users
          (username, enabled)
        values
          (${event.userName}, ${isEnabled})
        returning user_id`;
  
        }

 
        const groupId = event.request.userAttributes["custom:groupId"] ?? ""
        const userId = result[0].user_id ?? ""
        if (groupId) {
            await sql`insert into users_groups
            (group_id, user_id)
          values
            (${groupId}, ${userId}) returning user_id`;
        }
        const params = {
            UserPoolId: event.userPoolId,
            Username: event.userName,
            UserAttributes: [
                {
                    Name: 'custom:userId',
                    Value: userId.toString()
                }]
        };
        const command = new AdminUpdateUserAttributesCommand(params);
        await client.send(command);
    } catch (error) {
        console.error('Database connection error', error);
    }
    return event
};