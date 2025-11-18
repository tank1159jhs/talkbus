/*
  Warnings:

  - You are about to drop the column `roomId` on the `Membership` table. All the data in the column will be lost.
  - The `role` column on the `Membership` table would be dropped and recreated. This will lead to data loss if there is data in the column.
  - You are about to drop the column `roomId` on the `Message` table. All the data in the column will be lost.
  - You are about to drop the `Room` table. If the table is not empty, all the data it contains will be lost.
  - A unique constraint covering the columns `[userId,groupId]` on the table `Membership` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `groupId` to the `Membership` table without a default value. This is not possible if the table is not empty.
  - Added the required column `groupId` to the `Message` table without a default value. This is not possible if the table is not empty.

*/
-- CreateEnum
CREATE TYPE "public"."GroupRole" AS ENUM ('OWNER', 'MEMBER');

-- DropForeignKey
ALTER TABLE "public"."Membership" DROP CONSTRAINT "Membership_roomId_fkey";

-- DropForeignKey
ALTER TABLE "public"."Message" DROP CONSTRAINT "Message_roomId_fkey";

-- DropForeignKey
ALTER TABLE "public"."Room" DROP CONSTRAINT "Room_createdById_fkey";

-- DropIndex
DROP INDEX "public"."Membership_userId_roomId_key";

-- AlterTable
ALTER TABLE "public"."Membership" DROP COLUMN "roomId",
ADD COLUMN     "groupId" TEXT NOT NULL,
DROP COLUMN "role",
ADD COLUMN     "role" "public"."GroupRole" NOT NULL DEFAULT 'MEMBER';

-- AlterTable
ALTER TABLE "public"."Message" DROP COLUMN "roomId",
ADD COLUMN     "groupId" TEXT NOT NULL;

-- DropTable
DROP TABLE "public"."Room";

-- DropEnum
DROP TYPE "public"."RoomRole";

-- CreateTable
CREATE TABLE "public"."Talk" (
    "id" TEXT NOT NULL,
    "userAId" TEXT NOT NULL,
    "userBId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Talk_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."Chat" (
    "id" TEXT NOT NULL,
    "talkId" TEXT NOT NULL,
    "senderId" TEXT NOT NULL,
    "body" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Chat_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."Group" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Group_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "Talk_userAId_userBId_idx" ON "public"."Talk"("userAId", "userBId");

-- CreateIndex
CREATE UNIQUE INDEX "Membership_userId_groupId_key" ON "public"."Membership"("userId", "groupId");

-- CreateIndex
CREATE INDEX "Message_groupId_createdAt_idx" ON "public"."Message"("groupId", "createdAt");

-- AddForeignKey
ALTER TABLE "public"."Talk" ADD CONSTRAINT "Talk_userAId_fkey" FOREIGN KEY ("userAId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Talk" ADD CONSTRAINT "Talk_userBId_fkey" FOREIGN KEY ("userBId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Chat" ADD CONSTRAINT "Chat_talkId_fkey" FOREIGN KEY ("talkId") REFERENCES "public"."Talk"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Chat" ADD CONSTRAINT "Chat_senderId_fkey" FOREIGN KEY ("senderId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Membership" ADD CONSTRAINT "Membership_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "public"."Group"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Message" ADD CONSTRAINT "Message_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "public"."Group"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
