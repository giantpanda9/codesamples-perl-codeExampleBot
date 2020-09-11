#!/usr/bin/perl
use strict;
BEGIN { unshift @INC, './modules'; }
use ParseNASA;
use CodeExampleBot;

my $parseNASAinstance = ParseNASA->new;
my $NASAAPIResponse  = $parseNASAinstance->getDescription();
my $codeExampleBotInstance = CodeExampleBot->new;
$codeExampleBotInstance->setMessage($NASAAPIResponse);
my $telegramAPIResponse = $codeExampleBotInstance->sendMessage();
