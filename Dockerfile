FROM node:20-alpine
RUN npm install -g pnpm
WORKDIR /dashboard
COPY . .
RUN pnpm install
RUN echo "Node.js, pnpm, and application dependencies installed successfully."
EXPOSE 3000
CMD ["pnpm", "run", "dev"]
