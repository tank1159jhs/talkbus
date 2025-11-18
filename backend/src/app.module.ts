import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';

import { UsersModule } from './users/users.module';
import { AuthModule } from './auth/auth.module';

// ✅ 새로 추가
import { GroupsModule } from './groups/groups.module';
import { TalksModule } from './talks/talks.module';
import { TalkPostModule } from './talks/talkpost.module';

import { PrismaService } from './prisma.service';

import { I18nModule, QueryResolver, HeaderResolver, CookieResolver } from 'nestjs-i18n';
import { join } from 'path';

@Module({
  imports: [
    UsersModule,
    AuthModule,
    GroupsModule,
    TalksModule,
    TalkPostModule,
    I18nModule.forRoot({
      fallbackLanguage: 'ja',
      loaderOptions: {
        path: join(__dirname, '../i18n/'),
        watch: true,
      },
      resolvers: [
        { use: QueryResolver, options: ['lang'] },
        { use: HeaderResolver, options: ['accept-language'] },
        { use: CookieResolver, options: ['lang'] },
      ],
    }),
  ],
  controllers: [AppController],
  providers: [AppService, PrismaService],
})
export class AppModule {}
