# Auctioneer

A port of Ivaar's auctioneer for Ashita v4 with minimal modifications. https://github.com/Ivaar/Ashita-addons/tree/master/Auctioneer

This uses packets and can get you in trouble if you are doing things where you are not supposed to. 

It will block certain actions of you're not in a zone with an AH but still use at your own risk, you've been warned!

## Commands:

/auctioneer or /ah for all arguments. Price inputs do not have to have comma's. 

Item names with more than one term need to be quotations. Auto-translate should work but still has to be in quotations.

|**Argument**|**Description**|
|------------:|:---|
|menu|/ah or /ah menu will open the auction house menu and update whatever items you have for sale|
|buy|will place a bid. /ah buy [item] [single/stack] [price]|
||eg: /ah buy "silent oil" single 1,000,000|
|sell|same as buy but for selling. /ah sell [item] [single/stack] [price]|
||eg: /ah sell remedy stack 40000|
|show|will show the AH overlay(unless you have nothing up for sale)|
|hide|will hide the AH overlay|
||you can also you show and hide with other arguments to modify the AH overlay|
||date/timer/price/empty/slot are the additional arguments|
||eg: /ah hide empty (will no longer display empty AH slots on overlay)|
|clear|will clear out any sold/returned items AFTER you open the ah menu to update list|
|ibox/inbox|will open your inbox|
|obox/outbox|will open your outbox|

## To-Do's

General code clean up

Might put some more safety measures in place
