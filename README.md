# instagram-viewer
A simple photo browser for instagram

[gif demo](https://www.dropbox.com/s/dt0sybqqlsbjjnn/instagram-viewer-demo.gif?dl=1)

<br/>     				

Install
-------

- ```pod install``` Get all third party frameworks  
- Build and run

Feature
-------
- Pull to refresh
- Flexable cell height
- Auto load more

Description
-------
This app is for browsing photos from feeds. It contains grid view and table view to provides photo waterfall.

The core feature is "viewing", there are two way to layout the photo waterfall. Grid view could provides numbers of thumb in one screen. It is a good solution for quick browsing. Also user could click any thumb to enter table view for big image and author's comment. 

The API provide size for image, depended this and the comment string. It could pre-cauculate for making every cell flex to their height. It could save screen space. But I found many image is square size and contains top and bottom margin. So there is still have some blank spaces.

When scroll position is on top, user could pull down the list to reload latest post. When scroll position is approaching the bottom they could auto load order data in time-line . The grid view and table view use data from a singleton data source, for example when table view fetched new data, the grid view could use these data directly without making another API request. 

In user account view. It provide user's posts and likes.

If the time for developing is long enough. I think there should have "like" function.

