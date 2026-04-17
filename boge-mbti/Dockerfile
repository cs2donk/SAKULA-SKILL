# 第一阶段：构建前端产物
FROM node:18-alpine as builder

# 设置工作目录
WORKDIR /app

# 优先复制依赖文件并安装，利用 Docker 缓存加速构建
COPY package*.json ./
RUN npm install

# 复制其它所有项目文件（配合 .dockerignore 排除冗余文件）
COPY . .

# 执行 Vite 打包构建，产物会生成在 /app/dist 下
RUN npm run build

# 第二阶段：使用 Nginx 部署静态网页
FROM nginx:alpine

# 将构建好的静态文件复制到 Nginx 默认的主机目录下
COPY --from=builder /app/dist /usr/share/nginx/html

# 暴露容器内部的 80 端口
EXPOSE 80

# 启动 nginx 服务
CMD ["nginx", "-g", "daemon off;"]
