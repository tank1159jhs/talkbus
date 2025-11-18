import { IsString, IsOptional, MinLength } from 'class-validator';

export class StartTalkDto {
  @IsString()
  otherUserId: string;

  @IsOptional()
  @IsString()
  @MinLength(1)
  initialMessage?: string;
}
