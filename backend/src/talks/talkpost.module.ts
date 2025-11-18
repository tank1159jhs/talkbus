import { Module, forwardRef } from '@nestjs/common';
import { TalkPostService } from './talkpost.service';
import { TalkPostController } from './talkpost.controller';
import { PrismaService } from '../prisma.service';
import { TalksGateway } from './talks.gateway';
import { TalksModule } from './talks.module';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [forwardRef(() => TalksModule), AuthModule],
  providers: [TalkPostService, PrismaService],
  controllers: [TalkPostController],
})
export class TalkPostModule {}