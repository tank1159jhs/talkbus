/*
  Warnings:

  - You are about to drop the column `groupId` on the `Membership` table. All the data in the column will be lost.
  - You are about to drop the `Chat` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `Group` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `Message` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `Talk` table. If the table is not empty, all the data it contains will be lost.
  - A unique constraint covering the columns `[userId,groupRoomId]` on the table `Membership` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `groupRoomId` to the `Membership` table without a default value. This is not possible if the table is not empty.

*/
-- DropForeignKey
ALTER TABLE "public"."Chat" DROP CONSTRAINT "Chat_senderId_fkey";

-- DropForeignKey
ALTER TABLE "public"."Chat" DROP CONSTRAINT "Chat_talkId_fkey";

-- DropForeignKey
ALTER TABLE "public"."Membership" DROP CONSTRAINT "Membership_groupId_fkey";

-- DropForeignKey
ALTER TABLE "public"."Message" DROP CONSTRAINT "Message_authorId_fkey";

-- DropForeignKey
ALTER TABLE "public"."Message" DROP CONSTRAINT "Message_groupId_fkey";

-- DropForeignKey
ALTER TABLE "public"."Talk" DROP CONSTRAINT "Talk_userAId_fkey";

-- DropForeignKey
ALTER TABLE "public"."Talk" DROP CONSTRAINT "Talk_userBId_fkey";

-- DropIndex
DROP INDEX "public"."Membership_userId_groupId_key";

-- AlterTable
ALTER TABLE "public"."Membership" DROP COLUMN "groupId",
ADD COLUMN     "groupRoomId" TEXT NOT NULL;

-- DropTable
DROP TABLE "public"."Chat";

-- DropTable
DROP TABLE "public"."Group";

-- DropTable
DROP TABLE "public"."Message";

-- DropTable
DROP TABLE "public"."Talk";

-- CreateTable
CREATE TABLE "public"."DirectRoom" (
    "id" TEXT NOT NULL,
    "userAId" TEXT NOT NULL,
    "userBId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "DirectRoom_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."DirectMessage" (
    "id" TEXT NOT NULL,
    "directRoomId" TEXT NOT NULL,
    "senderId" TEXT NOT NULL,
    "body" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "DirectMessage_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."GroupRoom" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "GroupRoom_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."GroupMessage" (
    "id" TEXT NOT NULL,
    "groupRoomId" TEXT NOT NULL,
    "authorId" TEXT NOT NULL,
    "body" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "GroupMessage_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "DirectRoom_userAId_userBId_idx" ON "public"."DirectRoom"("userAId", "userBId");

-- CreateIndex
CREATE INDEX "GroupMessage_groupRoomId_createdAt_idx" ON "public"."GroupMessage"("groupRoomId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "Membership_userId_groupRoomId_key" ON "public"."Membership"("userId", "groupRoomId");

-- AddForeignKey
ALTER TABLE "public"."DirectRoom" ADD CONSTRAINT "DirectRoom_userAId_fkey" FOREIGN KEY ("userAId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."DirectRoom" ADD CONSTRAINT "DirectRoom_userBId_fkey" FOREIGN KEY ("userBId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."DirectMessage" ADD CONSTRAINT "DirectMessage_directRoomId_fkey" FOREIGN KEY ("directRoomId") REFERENCES "public"."DirectRoom"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."DirectMessage" ADD CONSTRAINT "DirectMessage_senderId_fkey" FOREIGN KEY ("senderId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Membership" ADD CONSTRAINT "Membership_groupRoomId_fkey" FOREIGN KEY ("groupRoomId") REFERENCES "public"."GroupRoom"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."GroupMessage" ADD CONSTRAINT "GroupMessage_groupRoomId_fkey" FOREIGN KEY ("groupRoomId") REFERENCES "public"."GroupRoom"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."GroupMessage" ADD CONSTRAINT "GroupMessage_authorId_fkey" FOREIGN KEY ("authorId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
