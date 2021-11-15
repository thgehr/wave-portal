from brownie import accounts, WavePortal, config, Wei


def deploy_wave_portal():
    account = accounts.add(config["wallets"]["from_key"])
    wave_portal = WavePortal.deploy({"from": account, "amount": Wei("0.02 ether")})


def wave():
    account = accounts.add(config["wallets"]["from_key"])
    wave_portal = WavePortal[-1]
    wave_portal.wave(
        "Second Wave from and to myself", {"from": account, "gas_limit": 300000}
    )


def getTotalWave():
    wave_portal = WavePortal[-1]
    print(wave_portal.getTotalWaves())


def main():
    # deploy_wave_portal()
    wave()
    # getTotalWave()
