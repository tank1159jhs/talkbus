import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  MessageBody,
  ConnectedSocket,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { JwtService } from '@nestjs/jwt';
import { TalksService } from './talks.service';
import { UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { I18nService } from 'nestjs-i18n';

@WebSocketGateway({
  cors: {
    origin: '*',
  },
})
export class TalksGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  constructor(
    private readonly talksService: TalksService,
    private readonly jwtService: JwtService,
    private readonly i18n: I18nService,
  ) {}

  async handleConnection(socket: Socket) {
    // JWT 인증 처리
    const token = socket.handshake.auth?.token || socket.handshake.query?.token;
    if (!token) {
      socket.emit('error', { message: await this.i18n.t('error.no_token') });
      socket.disconnect(true);
      return;
    }
    try {
      const payload = this.jwtService.verify(token);
      socket.data.user = payload;
      // 연결 알림 (전체 브로드캐스트)
      this.server.emit('userConnected', {
        userId: payload.userId,
        message: await this.i18n.t('user.connected'),
      });
    } catch (e) {
      socket.emit('error', {
        message: await this.i18n.t('error.invalid_token'),
      });
      socket.disconnect(true);
    }
  }

  handleDisconnect(socket: Socket) {
    // 연결 해제 시 전체에 알림
    const user = socket.data.user;
    if (user?.userId) {
      this.server.emit('userDisconnected', {
        userId: user.userId,
        message: this.i18n.t('user.disconnected'),
      });
    }
  }

  @SubscribeMessage('joinRoom')
  async handleJoinRoom(
    @MessageBody() data: { roomId: string },
    @ConnectedSocket() socket: Socket,
  ) {
    const user = socket.data.user;
    // 멤버십 체크 (그룹방)
    try {
      await this.talksService.createMessage({
        roomId: data.roomId,
        userId: user.userId,
        content: '', // 멤버십 체크만, 메시지는 저장하지 않음
      });
      socket.join(data.roomId);
      // 입장 알림 (해당 방에만)
      this.server.to(data.roomId).emit('userJoined', {
        userId: user.userId,
        message: await this.i18n.t('success.joined_room'),
      });
      return {
        success: true,
        message: await this.i18n.t('success.joined_room'),
      };
    } catch (e) {
      socket.emit('error', {
        message: await this.i18n.t('error.not_a_member'),
      });
      return { success: false, error: await this.i18n.t('error.not_a_member') };
    }
  }

  @SubscribeMessage('sendMessage')
  async handleSendMessage(
    @MessageBody() data: { roomId: string; content: string },
    @ConnectedSocket() socket: Socket,
  ) {
    const user = socket.data.user;
    // 메시지 DB 저장
    const message = await this.talksService.createMessage({
      roomId: data.roomId,
      userId: user.userId, // user.id → user.userId
      content: data.content,
    });
    // 해당 방에 메시지 브로드캐스트
    this.server.to(data.roomId).emit('newMessage', message);
    return { ...message, info: await this.i18n.t('success.message_sent') };
  }

  @SubscribeMessage('leaveRoom')
  async handleLeaveRoom(
    @MessageBody() data: { roomId: string },
    @ConnectedSocket() socket: Socket,
  ) {
    const user = socket.data.user;
    socket.leave(data.roomId);
    this.server.to(data.roomId).emit('userLeft', {
      userId: user.userId,
      message: await this.i18n.t('success.left_room'),
    });
    return { success: true, message: await this.i18n.t('success.left_room') };
  }

  @SubscribeMessage('getOnlineUsers')
  async handleGetOnlineUsers(@ConnectedSocket() socket: Socket) {
    // socket.io의 connected sockets에서 userId 목록 추출
    const users: string[] = [];
    for (const [id, s] of this.server.sockets.sockets) {
      if (s.data?.user?.userId) {
        users.push(s.data.user.userId);
      }
    }
    socket.emit('onlineUsers', users);
    return users;
  }

  @SubscribeMessage('getRoomUsers')
  async handleGetRoomUsers(
    @MessageBody() data: { roomId: string },
    @ConnectedSocket() socket: Socket,
  ) {
    const roomSockets = this.server.sockets.adapter.rooms.get(data.roomId);
    const userIds: string[] = [];
    if (roomSockets) {
      for (const socketId of roomSockets) {
        const s = this.server.sockets.sockets.get(socketId);
        if (s?.data?.user?.userId) {
          userIds.push(s.data.user.userId);
        }
      }
    }
    socket.emit('roomUsers', { roomId: data.roomId, userIds });
    return userIds;
  }
}
