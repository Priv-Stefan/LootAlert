# LootAlert
A simple wishlist WoW© 3.3.5a addon 

## What is it good for
This addon is a small list of items you may want to roll for when in a raid, e.g. ICC or Ruby. It's purpose is to hold track of what you want for your level 80 char.

![LootAlert](lootalert.png)

<small>Artwork by Blizzard Entertainment, Inc®</small>

The lower list shows the already looted items, so you can keep of track of items to be rolled for later.

If an item from the wishlist was looted, it is shown with a green background.

Items are added by entering the item name or part of the item name into the input field in the left right corner, e.g. "Gruftm". You can use the item name in your WoW© language. It is recommendend, to click the "Scan" once, WoW© was started. This loads all epic+ items starting with id 40000 in an array. That allows to search for items, which have not yet seen by the char.

If an item was not found, the entered item name is written into the textbox with a leading "nf " text.

If the mouse hovers over the item icon, the usual tooltip is shown. If the shift key was pressed while the mouse was moved over the item item, the usual tooltip and the compare tooltops (ShoppingToolTip) of currently equipped items for compare.

If a raid warning contains the link of one of the items in the wishlist an alert sound is played. (`sound\\interface\\PVPFlagTakenHordeMono.wav` )

(That was the idea behind "lootAlert".)

This little addon is still under devlopement. 

If the addon was closed, simply enter "/lola" in the chat to reopen the addon window.

The addon was developed while playing on [Rising Gods](https://www.rising-gods.de/), a free German 3.3.5a server.

## Installing
Download LootAlert.zip. Change in `Interface/AddOns` directory and unzip the files by keeping the file and directory structure. A new directory `LootAlert` is created with four new files in. 

Use on your own risk.

## Open issues
When adding and item, it is not clear, whether it is heroic nor normal. Need to save both item Ids: normal and heroic. 

