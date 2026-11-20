# Source patches

The game's source changes, as `git am` patch series.

- `spaghettikart/`: apply to [SpaghettiKart](https://github.com/HarbourMasters/SpaghettiKart) at commit `ce0f935` ("Allow Match Refresh Rate for every renderer (#769)").
- `libultraship/`: apply to [libultraship](https://github.com/Kenix3/libultraship) at commit `60c9bb7`, in the `libultraship` submodule.

```
git clone https://github.com/HarbourMasters/SpaghettiKart && cd SpaghettiKart
git checkout ce0f935 && git am ../patches/spaghettikart/*.patch
git submodule update --init torch
git clone https://github.com/Kenix3/libultraship && (cd libultraship && git checkout 60c9bb7 && git am ../../patches/libultraship/*.patch)
```
