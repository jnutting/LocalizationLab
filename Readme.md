
## Overview

The files inside the `LocalizedStringsManagement` directory are meant to be fairly general-purpose, and could potentially be dropped into an existing module with other common code or into a module of their own. In either case, they would need a bit of tweaking. In particular, the `LocalizedStringsViewModel` class will need to contain (or have passed in or injected) the correct URL for fetching localized strings from the CMS.

The top-level files in the project are all pretty self-explanatory.

## Usage

The main usage is pretty straightforward, and can be seen in the `ContentView`. Inject or create an instance of LocalizedStringsViewModel in any view or other type that needs it:

```
    @StateObject var ls = LocalizedStringsViewModel()
```

Then, look for a localized string based on a key like this:

```
    Text(ls.s("titleText"))
```

In this case, I purposely named this viewmodel property `ls` and gave it a very shortly-named string lookup method `s` for the sake of brevity and quick typing: "ls.s" can be quickly typed with two fingers :D

If the `s` method doesn't find any entry corresponding to the given key, it will simply return the key itself. For this reason, you might want to choose to use keys that are relatively easy for a user to read, in case something goes wrong.

## Under the hood

The files in the LocalizedStringManagement directory are mostly implicitly `internal`, with only a couple available as `public`. 

One of the public types is a protocol called DataArchiver, which in this case is used for caching a set of localizations fetched from a remote URL, specifically through the concreate type LocalizedStringsArchiver. I made the base protocol `public` because it might be useful in other parts of the app, such as when you are storing an audio file. This archiver encapsulates both file storage and storage of the file's URL in user defaults based off a key, the point being that you don't need to worry about file systems and user defaults all over the place, you just deal with an instance of a type as a "facade" that can store data and give you an URL to retrieve the stored data.

The main `public` type here is LocalizedStringsViewModel, which has just a single public property called `strings` (which is in fact a dictionary of key-value pairs for lookup). The `strings` property can be used directly from views, viewmodels, or anywhere else, but the `s()` function mentioned earlier is also available, and has the added feature of returning the key itself if there is no matching value for the key.

This viewmodel works by merging the results of two different repositories of localized strings: one stored on the device, and one fetched from a remote URL. These two are combined with `MergeMany`, the result ending up in the `strings` property. What this means is that `strings` will at first contain the values read immediately from local storage, which will then be replaced by what is retrieved from the remote URL. So if you create a single instance of this viewmodel (e.g. in AppConfig to inject everywhere), it will start trying to fetch values from the remote URL right away, and those values will probably be retrieved before many (or any) views have actually appeared yet. In this demo app, when you first launch in the simulator you'll see that the built-in values from `EmbeddedStrings.json` can be seen in the view briefly, and they are then replaced by the values fetched from a remote URL.
