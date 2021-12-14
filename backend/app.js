const express = require("express");
const fs = require("fs");
const bodyParser = require("body-parser");
const multer = require("multer");
const mongoose = require("mongoose");
const cors = require("cors");
const cookieParser = require("cookie-parser");

//Routes
const authRoutes = require("./routes/auth");
const userRoutes = require("./routes/user");
const playlistRoutes = require("./routes/playlist");
const authorizationCodeRoutes = require("./routes/authorization-code");
const eventRoutes = require("./routes/event");
const searchRoutes = require("./routes/search");
const meRoutes = require("./routes/me");

//Swagger
const jsyaml = require("js-yaml");
const swaggerUI = require("swagger-ui-express");

const spec = fs.readFileSync("./api/swagger.yaml", "utf-8");
const swaggerDocument = jsyaml.safeLoad(spec);

const upload = multer();
const app = express();

//MongoDB atlas
mongoose
  .connect(
    "mongodb+srv://musicroom:musicroom42@cluster0.twzgy.mongodb.net/myFirstDatabase?retryWrites=true&w=majority",
    { useNewUrlParser: true, useUnifiedTopology: true }
  )
  .then(() => console.log("Connexion a MongoDB reussie !"))
  .catch(() => console.log("Connexion a MongoDB echouee !"));

app.use((req, res, next) => {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader(
    "Access-Control-Allow-Headers",
    "Origin, X-Requested-Width, Content, Accept, Content-Type, Authorization"
  );
  res.setHeader(
    "Access-Control-Allow-Methods",
    "GET, POST, PUT, DELETE, PATCH, OPTIONS"
  );
  next();
});

app.disable("etag");
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(upload.array());
app.use(express.static("public"));
app.use(cors()).use(cookieParser());

app.use("/api-docs", swaggerUI.serve, swaggerUI.setup(swaggerDocument));
app.use("/api/auth", authRoutes);
app.use("/spotify/authorization_code", authorizationCodeRoutes);
app.use("/api/users", userRoutes);
app.use("/api/playlists", playlistRoutes);
app.use("/api/events", eventRoutes);
app.use("/api/search", searchRoutes);
app.use("/api/me", meRoutes);

module.exports = app;
