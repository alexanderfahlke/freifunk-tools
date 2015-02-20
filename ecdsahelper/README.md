# What's this?

This is a little helper script that will do a few things for you, you otherwise needed to do manually.

1. resynchronize the apt package index files from their sources
2. install some tools you need to get this thing working

  ```
  git
  pkg-config
  cmake
  doxygen
  ```

3. make and install ```libuecc```

    ```libuecc``` is a very small Elliptic Curve Cryptography library.

    See [http://git.universe-factory.net/libuecc](http://git.universe-factory.net/libuecc) for more details.

4. make and install ```ecdsakeygen```

    See [https://github.com/tcatm/ecdsautils](https://github.com/tcatm/ecdsautils) for more details.

5. Generate a new ecdsa key pair for signing the firmware
