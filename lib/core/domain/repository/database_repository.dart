/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

abstract class DatabaseRepository {
  Future<void> updateUserStatus(bool status);
  Stream<bool> getUserStatus(String userID);
  Future<void> updateUserTypingStatus(bool status);
  Stream<bool> getUserTypingStatus(String userID);
}
