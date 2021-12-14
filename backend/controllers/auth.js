const {
  UserInfo,
  UserData,
  User,
  ActivateAccount,
  LoginObject,
} = require("../models/User");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const transporter = require("../mail.js");
const { OAuth2Client } = require("google-auth-library");
const axios = require("axios");

const CLIENT_ID =
  "524786201017-giagchb12v60sefkfvhp0vbldap7hfak.apps.googleusercontent.com";

async function sendValidationMail(user, activationKey) {
  return new Promise((resolve, reject) => {
    const mailData = {
      from: '"MusicRoom" <' + transporter.options.auth.user + ">",
      to: user.userInfo.email,
      subject: "Music Room - Account validation",
      text: "",
      html:
        "<b>Hey " +
        user.userInfo.firstName +
        "</b> \
			 	<br>Click http://localhost:45559/api/auth/activate/" +
        user._id +
        "/" +
        activationKey +
        " to activate your MusicRoom account.<br/>",
    };
    console.log("HELLO WORDL1");
    transporter.sendMail(mailData, function (err, info) {
      if (err) reject(err);
      else resolve(info);
    });
  });
}

async function saveUserToDataBase(user) {
  let otherUser = await User.findOne({ "userInfo.email": user.userInfo.email });
  if (otherUser) {
    throw new Error("Duplicate email!");
  }
  otherUser = await User.findOne({ "userInfo.pseudo": user.userInfo.pseudo });
  if (otherUser) {
    throw new Error("Duplicate pseudo!");
  }
  if (!user.userInfo.active) {
    const activateAccount = new ActivateAccount({
      userId: user._id,
      randomKey: require("crypto").randomBytes(64).toString("hex"),
    });
    await activateAccount.save();
    await user.save();
    return activateAccount.randomKey;
  }
  await user.save();
}

async function createUserFromBody(req) {
  if (!req.body.password || req.body.password.length < 5)
    throw new Error("Password is required!");
  const userInfo = new UserInfo({
    ...req.body,
    registrationDate: new Date().getTime(),
    password: await bcrypt.hash(req.body.password, 10),
  });
  const userData = new UserData();
  const user = new User({
    userInfo: userInfo,
    userData: userData,
  });
  return user;
}

async function verifyGoogleToken(req) {
  console.log(req.body);
  if (!req.body.token || !req.body.MusicRoom_ID)
    throw new Error("Missing token or MusicRoom_ID field!");
  const client = new OAuth2Client(CLIENT_ID);
  const ticket = await client
    .verifyIdToken({
      idToken: req.body.token,
      audience: req.body.MusicRoom_ID,
    })
    .catch((err) => {
      throw new Error("Auth with Google failed, invalid token or client id!");
    });
  return ticket.getPayload();
}

async function createUserFromGoogle(req) {
  const payload = await verifyGoogleToken(req);
  const userInfo = new UserInfo({
    firstName: payload.given_name,
    lastName: payload.family_name,
    pseudo:
      payload.given_name + require("crypto").randomBytes(5).toString("hex"),
    email: payload.email,
    password: require("crypto").randomBytes(2).toString("hex"),
    registrationDate: new Date().getTime(),
    active: payload.email_verified,
  });
  const userData = new UserData();
  const user = new User({
    userInfo: userInfo,
    userData: userData,
  });
  return user;
}

async function verifyFacebookToken(req) {
  if (!req.body.token) throw new Error("Missing token field!");
  console.log(req.body.token);
  const { data } = await axios({
    url: "https://graph.facebook.com/me",
    method: "get",
    params: {
      fields: ["email", "first_name", "last_name"].join(","),
      access_token: req.body.token,
    },
  }).catch(() => {
    throw new Error("Auth with Facebook failed, invalid token!");
  });
  return { data };
}

async function createUserFromFacebook(req) {
  const { data } = await verifyFacebookToken(req);
  const userInfo = new UserInfo({
    firstName: data.first_name,
    lastName: data.last_name,
    pseudo: data.first_name + require("crypto").randomBytes(2).toString("hex"),
    email: data.email,
    password: require("crypto").randomBytes(10).toString("hex"),
    registrationDate: new Date().getTime(),
    active: true,
  });
  const userData = new UserData();
  const user = new User({
    userInfo: userInfo,
    userData: userData,
  });
  return user;
}

async function createUserFromSource(req) {
  let user;

  if (req.url.indexOf("/signup/google") != -1) {
    user = await createUserFromGoogle(req).catch((err) => {
      throw {
        message: err.message,
        source: "google",
      };
    });
  } else if (req.url.indexOf("/signup/facebook") != -1) {
    user = await createUserFromFacebook(req).catch((err) => {
      throw {
        message: err.message,
        source: "facebook",
      };
    });
  } else {
    user = await createUserFromBody(req);
  }
  return user;
}

function parseGoogleSignupErrors(res, err) {
  if (err.message) console.log(err.message);
  if (err.message.indexOf("Duplicate email!") != -1) {
    console.log("Email already assign to a MusicRoom account!");
    res.status(400).json({ code: "0" });
  } else if (err.message === "Missing token or MusicRoom_ID field!") {
    res.status(400).json({ code: "1" });
  } else if (
    err.message === "Auth with Google failed, invalid token or client id!"
  ) {
    res.status(400).json({ code: "2" });
  } else {
    console.log(err);
    res.status(500).json({ code: "0" });
  }
}

function parseFacebookSignupErrors(res, err) {
  if (err.message) console.log(err.message);
  if (err.message.indexOf("Duplicate email!") != -1) {
    console.log("Email already assign to a MusicRoom account!");
    res.status(400).json({ code: "0" });
  } else if (err.message === "Missing token field!") {
    res.status(400).json({ code: "1" });
  } else if (err.message === "Auth with Facebook failed, invalid token!") {
    res.status(400).json({ code: "2" });
  } else {
    console.log(err);
    res.status(500).json({ code: "0" });
  }
}

function parseSignupErrors(req, res, err) {
  if (req.url.indexOf("/signup/google") != -1) {
    parseGoogleSignupErrors(res, err);
  } else if (req.url.indexOf("/signup/facebook") != -1) {
    parseFacebookSignupErrors(res, err);
  } else {
    if (err.message.indexOf("Duplicate email!") != -1) {
      console.log("Email already assign to a MusicRoom account!");
      res.status(400).json({ code: "1" });
    } else if (err.message.indexOf("Duplicate pseudo!") != -1) {
      console.log("Pseudo already assign to a MusicRoom account!");
      res.status(400).json({ code: "0" });
    } else if (err.message.indexOf("required") != -1) {
      console.log(err.message);
      res.status(400).json({ code: "2" });
    } else {
      console.log(err);
      res.status(500).json({ code: "0" });
    }
  }
}

function parseResponseCode(req, res, user) {
  if (req.url.indexOf("/signup/google") != -1) {
    if (user.userInfo.active == false) {
      res.status(201).json({ code: "0" });
    } else {
      res.status(201).json({ code: "1" });
    }
  } else if (req.url.indexOf("/signup/facebook") != -1) {
    res.status(201).json({ code: "0" });
  } else {
    res.status(201).json({ code: "0" });
  }
}

exports.signup = async (req, res, next) => {
  try {
    let user = await createUserFromSource(req);
    const activationKey = await saveUserToDataBase(user);
    // if (!user.userInfo.active) await sendValidationMail(user, activationKey);
    parseResponseCode(req, res, user);
  } catch (err) {
    parseSignupErrors(req, res, err);
  }
};

function parseGoogleLoginErrors(res, err) {
  if (err.message) console.log(err.message);
  if (err.message === "Missing token or MusicRoom_ID field!") {
    res.status(400).json({ code: "2" });
  } else if (
    err.message === "Auth with Google failed, invalid token or client id!"
  ) {
    res.status(400).json({ code: "3" });
  } else {
    console.log(err);
    res.status(500).json({ code: "0" });
  }
}

function parseFacebookLoginErrors(res, err) {
  if (err.message) console.log(err.message);
  if (err.message === "Missing token field!") {
    res.status(400).json({ code: "1" });
  } else if (err.message === "Auth with Facebook failed, invalid token!") {
    res.status(400).json({ code: "2" });
  } else {
    console.log(err);
    res.status(500).json({ code: "0" });
  }
}

function parseLoginErrors(req, res, err) {
  if (err.source && err.source === "google") {
    parseGoogleLoginErrors(res, err);
  } else if (err.source && err.source === "facebook") {
    parseFacebookLoginErrors(res, err);
  } else {
    if (err.message) console.log(err.message);
    if (err.message == "Missing email or password field!") {
      res.status(400).json({ code: "0" });
    } else if (err.message == "Invalid user email!") {
      if (
        req.url.indexOf("/login/google") != -1 ||
        req.url.indexOf("/login/facebook") != -1
      )
        res.status(400).json({ code: "0" });
      else res.status(400).json({ code: "1" });
    } else if (err.message == "Account is not activated yet!") {
      if (req.url.indexOf("/login/google") != -1)
        res.status(400).json({ code: "1" });
      else res.status(400).json({ code: "2" });
    } else if (err.message == "Invalid password!") {
      res.status(400).json({ code: "3" });
    } else if (
      err.message == "User account temporarily blocked, try again in 5 minutes!"
    ) {
      res.status(400).json({ code: "4" });
    } else {
      console.log("Erreur non gérée!");
      console.log(err);
      res.status(500).json({ code: "0" });
    }
  }
}

async function retrieveUserFromSource(req) {
  let email;
  let user;

  if (req.url.indexOf("/login/google") != -1) {
    const payload = await verifyGoogleToken(req).catch((err) => {
      throw {
        message: err.message,
        source: "google",
      };
    });
    email = payload.email;
  } else if (req.url.indexOf("/login/facebook") != -1) {
    const { data } = await verifyFacebookToken(req).catch((err) => {
      throw {
        message: err.message,
        source: "facebook",
      };
    });
    email = data.email;
  } else {
    if (!req.body.email || !req.body.password)
      throw new Error("Missing email or password field!");
    email = req.body.email;
  }
  user = await User.find({
    $or: [{ "userInfo.email": email }, { "userInfo.secondaryEmail": email }],
  });
  return user[0];
}

exports.login = async (req, res, next) => {
  try {
    user = await retrieveUserFromSource(req);
    if (!user) throw new Error("Invalid user email!");
    else if (user.userInfo.active == false)
      throw new Error("Account is not activated yet!");
    else if (
      user.userInfo.login &&
      user.userInfo.login.tryPasswordTimes >= 5 &&
      new Date().getTime() - user.userInfo.login.lastLoginDate.getTime() <
        5 * 60 * 1000
    ) {
      console.log(
        (new Date().getTime() - user.userInfo.login.lastLoginDate.getTime()) /
          1000 /
          60
      );
      throw new Error(
        "User account temporarily blocked, try again in 5 minutes!"
      );
    } else if (
      (req.url == "/login" || req.url == "/login/") &&
      !(await bcrypt.compare(req.body.password, user.userInfo.password))
    ) {
      if (!user.userInfo.login) {
        user.userInfo.login = new LoginObject({
          tryPasswordTimes: 0,
          lastLoginDate: new Date().getTime(),
        });
      }
      user.userInfo.login.lastLoginDate = new Date().getTime();
      user.userInfo.login.tryPasswordTimes += 1;
      user.save();
      throw new Error("Invalid password!");
    } else {
      if (!user.userInfo.login) {
        user.userInfo.login = new LoginObject({
          tryPasswordTimes: 0,
          lastLoginDate: new Date().getTime(),
        });
      } else {
        user.userInfo.login.lastLoginDate = new Date().getTime();
        user.userInfo.login.tryPasswordTimes = 0;
      }
      user.save();
    }
    res.status(200).json({
      code: "0",
      userId: user._id,
      userPseudo: user.userInfo.pseudo,
      token: jwt.sign({ userId: user._id }, "RANDOM_TOKEN_SECRET", {
        expiresIn: "24h",
      }),
    });
  } catch (err) {
    parseLoginErrors(req, res, err);
  }
};

//private function
function randomPassword(length) {
  var result = "";
  var characters =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
  var charactersLength = characters.length;
  for (var i = 0; i < length; i++) {
    result += characters.charAt(Math.floor(Math.random() * charactersLength));
  }
  return result;
}

exports.sendMailResetPassword = (req, res, next) => {
  if (!req.body.email) {
    return res.status(400).json({ error: "User's email must be specified!" });
  }
  User.findOne({ "userInfo.email": req.body.email })
    .then((user) => {
      if (!user) {
        return res.status(400).json({ error: "Couldn't find the user!" });
      }
      let password = randomPassword(12);
      bcrypt.hash(password, 10).then((hash) => {
        user.userInfo.password = hash;
        user.save();
      });
      let mailData = {
        from: '"MusicRoom application" <' + transporter.options.auth.user + ">",
        to: user.userInfo.email,
        subject: "Reseting password",
        text:
          "Hello, you asked us to reset your password. You can now connect on MusicRoom with this password : " +
          password,
        html:
          "Hello, you asked us to reset your password. You can now connect on MusicRoom with this password : " +
          password,
      };
      transporter.sendMail(mailData, (error, info) => {
        if (error) {
          return console.log(error);
        }
        res
          .status(200)
          .json({ message: "Mail send!", message_id: info.message_id });
      });
    })
    .catch((error) => res.status(500).json({ error }));
};

function parseActivateErrors(res, err) {
  if (err.message) console.log(err.message);
  if (err.message == "Invalid user id, invalid url!") {
    res.status(400).json({ code: "1" });
  } else if (err.message == "User account is already active!") {
    res.status(400).json({ code: "2" });
  } else if (
    err.message == "Url hash id do not match with DB hash!, invalid url!"
  ) {
    res.status(400).json({ code: "3" });
  } else {
    console.log("Unhandled/server error in validate account root!");
    console.log(err);
    res.status(400).json({ code: "4" });
  }
}

exports.activate = async (req, res, next) => {
  try {
    let user = await User.findOne({ _id: req.params.userId });
    if (!user) throw new Error("Invalid user id, invalid url!");
    if (user.userInfo.active == true)
      throw new Error("User account is already active!");
    let activeAccount = await ActivateAccount.findOne({
      userId: req.params.userId,
    });
    if (req.params.hashId != activeAccount.randomKey)
      throw new Error("Url hash id do not match with DB hash!, invalid url!");
    user.userInfo.active = true;
    await user.save();
    await ActivateAccount.deleteOne({ userId: req.params.userId });
    res.status(200).json({ code: "0" });
  } catch (err) {
    parseActivateErrors(res, err);
  }
};
