# DUST HACK #1 - Voting

This repository contains the smart contract and app for the project submission and voting of the first DUST HACK.

## VotingSystem

A MUD system to facilitate voting. The namespace owner can register moderators, moderators can register participants, participants can submit projects and vote for projects. Each participant gets 3 votes, which can be distributed among the projects. Multiple votes for per project are possible, voting for the own project is not possible. Votes can be changed at any point until the end of the voting period.

## ChestPrizeProgram

A DUST program to allow anyone to donate prize items to a chest, and automatically let the winner withdraw the items after the end of the voting period.

## App

A frontend for submitting projects, exploring projects, and voting for projects. When opened [outside the DUST client](https://dust-hack-voting.vercel.app/) only exploring submitted projects is possible. When opened as an [app inside the DUST client](https://alpha.dustproject.org/?open-app=https://dust-hack-voting.vercel.app/dust-app.json), registered participants can additionally submit projects, edit their projects, and vote for projects.
