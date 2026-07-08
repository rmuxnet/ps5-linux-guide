# Supported Firmware

Currently documented for **PS5 Phat/Slim**, firmware **3.00-7.61**. Whether higher firmware or PS5 Pro model will ever be supported - we genuinely don't know, and we don't want to jinx anything.

## Exploitable Versions

| Firmware | M.2 Support | Exploit |
|---|---|---|
| 3.00, 3.10, 3.20, 3.21 | ✗ | umtx2 |
| 4.00, 4.02, 4.03, 4.50, 4.51 | ✓ | umtx2 |
| 5.00, 5.02, 5.10, 5.50 | ✓ | umtx2 |
| 6.00, 6.02, 6.50 | ✓ | Y2JB |
| 7.20, 7.40, 7.61 | ✓ | Y2JB |

::: info Why no M.2 on 3.xx?
The PS5 fails to boot with an M.2 attached on 3.xx firmware.
:::

## Which Firmware Should I Be On?

There is **no performance difference** between any supported firmware version for Linux.

Community recommendations:

| Goal | Recommended firmware |
|---|---|
| No M.2, Linux only | **3.00** - stay as low as possible |
| M.2 + PS5 games + Linux | **4.03** - community favorite, full jailbreak support, backports, up to 4TB M.2 |
| Already on 5.xx/6.02/7.xx/7.61 | Fine to stay, no downsides for Linux |


::: info 6.02/7.61 jailbreak is more tedious
6.02/7.61 uses Y2JB which must be re-run every time. 3.xx-5.50 uses umtx2 which is simpler.
:::

## Check Your Firmware

`Settings` → `System` → `System Software` → `System Software Version`

## Updating to a Specific Firmware

Download the correct PUP from [darthsternie.net/ps5-firmwares](https://darthsternie.net/ps5-firmwares/) and follow the [official Sony guide](https://www.playstation.com/en-us/support/hardware/reinstall-playstation-system-software-safe-mode). You cannot downgrade.
