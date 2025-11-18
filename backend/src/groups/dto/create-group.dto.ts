import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty } from 'class-validator';

export class CreateGroupDto {
  @ApiProperty({ description: '그룹방 제목', example: '스터디 그룹' })
  @IsString()
  @IsNotEmpty()
  title: string;
}
