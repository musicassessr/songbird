"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.handler = void 0;
const postgres_1 = __importDefault(require("postgres"));
const client_cognito_identity_provider_1 = require("@aws-sdk/client-cognito-identity-provider");
const sql = (0, postgres_1.default)({
    host: process.env.MUSICASSESSR_DB_HOST,
    port: 5432,
    database: process.env.MUSICASSESSR_DB_NAME,
    username: process.env.MUSICASSESSR_DB_USER,
    password: process.env.MUSICASSESSR_DB_PASSWORD,
    ssl: { rejectUnauthorized: false }
});
const client = new client_cognito_identity_provider_1.CognitoIdentityProviderClient();
const isEnabled = true;
const handler = (event) => __awaiter(void 0, void 0, void 0, function* () {
    var _a, _b, _c;
    console.log(event);
    try {
        const email = (_a = event.request.userAttributes.email) !== null && _a !== void 0 ? _a : "";
        let result;
        if (email) {
            result = yield sql `insert into users
            (username, enabled, email)
          values
            (${event.userName}, ${isEnabled}, ${email})  returning user_id`;
        }
        result = yield sql `insert into users
        (username, enabled)
      values
        (${event.userName}, ${isEnabled})
      returning user_id`;
        const groupId = (_b = event.request.userAttributes["custom:groupId"]) !== null && _b !== void 0 ? _b : "";
        const userId = (_c = result[0].user_id) !== null && _c !== void 0 ? _c : "";
        if (groupId) {
            yield sql `insert into users_groups
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
                }
            ]
        };
        const command = new client_cognito_identity_provider_1.AdminUpdateUserAttributesCommand(params);
        yield client.send(command);
    }
    catch (error) {
        console.error('Database connection error', error);
    }
    return event;
});
exports.handler = handler;
