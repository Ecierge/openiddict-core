namespace Apple.CryptoKit;

using System;
using Foundation;
using System.Runtime.InteropServices;

[BaseType(typeof(NSObject))]
interface ACKeychainStorage
{
    [Static]
    [Export("isKeyExist:isPublic:")]
    public bool IsKeyExist(string keyName, bool isPublic);

    [Static]
    [Export("getKey:isPublic:")]
    public NSData GetKey(string keyName, bool isPublic);

    [Static]
    [Export("createRSAKeyAnsStoreInkeychain:algorithm:keySize:isKeyPublic:keyUsage:overwrite:")]
    public NSData CreateKey(string keyName, string algorithm, int keySize, bool isPublic, bool keyUsages, bool overwrite);
}

