import { IsString, MinLength } from 'class-validator';

export class SendGroupMessageDto {
  @IsString()
  @MinLength(1)
  body: string;
}
