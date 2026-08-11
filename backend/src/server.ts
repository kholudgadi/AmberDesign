import { createServer } from "node:http";
import { app } from "./app.js";
import { env } from "./config.js";
import { prisma } from "./database.js";
import { configureSocket } from "./socket.js";

const server = createServer(app);
configureSocket(server);

async function start() {
  await prisma.$connect();
  server.listen(env.PORT, () => console.log(`AmberDesign API and Socket.io listening on :${env.PORT}; PostgreSQL connected`));
}

start().catch(error => {
  console.error("Unable to connect to PostgreSQL; server was not started", error);
  process.exit(1);
});

const shutdown = (signal: string) => {
  console.log(`${signal} received; closing server`);
  server.close(() => void prisma.$disconnect().finally(() => process.exit(0)));
  setTimeout(() => process.exit(1), 10_000).unref();
};
process.on("SIGTERM", () => shutdown("SIGTERM"));
process.on("SIGINT", () => shutdown("SIGINT"));
