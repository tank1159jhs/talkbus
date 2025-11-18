import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { IoAdapter } from '@nestjs/platform-socket.io';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // WebSocket 어댑터 설정
  app.useWebSocketAdapter(new IoAdapter(app));

  app.useGlobalPipes(
    new ValidationPipe({
      transform: true, // ⚡️ body → DTO로 변환
      whitelist: true, // ⚡️ DTO에 정의 안 된 속성은 자동 제거
      forbidNonWhitelisted: true, // ⚡️ DTO에 없는 속성 들어오면 에러
    }),
  );

  // Swagger 설정
  const config = new DocumentBuilder()
    .setTitle('TalkBus API')
    .setDescription('Chat/Group Messaging API Docs')
    .setVersion('1.0')
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api-docs', app, document);

  await app.listen(process.env.PORT || 3000);
}
bootstrap();
