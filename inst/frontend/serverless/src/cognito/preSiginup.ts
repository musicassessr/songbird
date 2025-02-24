import postgres from 'postgres';

const sql = postgres({
    host: process.env.MUSICASSESSR_DB_HOST,
    port: 5432,
    database: process.env.MUSICASSESSR_DB_NAME,
    username: process.env.MUSICASSESSR_DB_USER,
    password: process.env.MUSICASSESSR_DB_PASSWORD,
    ssl: { rejectUnauthorized: false }
});


export const handler = async (event) => {
    const username = event.userName;

    // const usernameRegex = /^[0-9]{6}[A-Z]{2}[0-9]{2}(_[0-9]+)?$/;

    // if (!usernameRegex.test(username)) {
    //     throw new Error("Invalid username format");
    // }

    const result = await sql`select * from users where username = ${username}`;

    if (result.count > 0) {
        throw new Error("User already exists");
    }

    event.response.autoConfirmUser = true;

    return event;
};