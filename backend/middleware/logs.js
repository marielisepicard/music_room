const fs = require("fs");
const eventFctn = require("../controllers/event");

module.exports = (req, res, next) => {
  let log;
  const logDate = new Date();

  let fileName = "./logs/" + eventFctn.getUserIdFromToken(req) + ".logs";
  log = "date=" + logDate.toISOString() + ";";
  log += "deviceModel=" + req.headers.devicemodel + ";";
  log += "deviceOSVersion=" + req.headers.deviceosversion + ";";
  log += "musicRoomVersion=" + req.headers.musicroomversion + ";";
  log +=
    "root=" + req.protocol + "://" + req.get("host") + req.originalUrl + ";";
  log += "statusCode=" + res.statusCode.toString() + ";";
  log += "message=" + res.musicRoomMessage + "\r\n";
  fs.appendFile(fileName, log, (err) => {
    if (err) {
      console.log(err);
      console.log("Error when trying to write log!");
    } else {
    }
  });
  console.log(log);
  next();
};
