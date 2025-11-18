import { Module } from '@nestjs/common';
import { TalksService } from './talks.service';
import { TalksController } from './talks.controller';
import { PrismaService } from '../prisma.service';
import { TalkPostModule } from './talkpost.module';
import { TalksGateway } from './talks.gateway';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [AuthModule, TalkPostModule],
  controllers: [TalksController],
  providers: [TalksService, PrismaService, TalksGateway],
  exports: [TalksService, TalksGateway], 
})
export class TalksModule {}
