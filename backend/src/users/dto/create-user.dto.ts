import { IsEmail, IsString, MinLength } from 'class-validator';

export class CreateUserDto {
  @IsEmail()
  email: string;

  @IsString()
  nickname: string;

  @MinLength(6)
  passwordHash: string;

  @IsString()
  displayName: string;
}
