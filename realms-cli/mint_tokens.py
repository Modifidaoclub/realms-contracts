
from nile import deployments
INITIAL_LORDS_SUPPLY = 500000000 * (10 ** 18)
NETWORK = "goerli"

def run(nre):
    admin = '0x00b8675fba812edd0f69fcb917616162cbe785490aeabfb693fb3a0f489a21a5'
    
    address, abi = nre.deploy("Lords_ERC20_Mintable", alias="lords", arguments=[
        "123",
        "1234",
        "18",
        str(INITIAL_LORDS_SUPPLY),
        "0",
        admin,
        admin])

    print(address, abi)

    realms = nre.deploy(
        "Realms_ERC721_Mintable", 
        alias="realms",
        arguments=[
            "1234",  # name
            "1234",  # ticker
            admin,  # contract_owner
        ],
    )
    print(realms)

    s_realms = nre.deploy(
        "S_Realms_ERC721_Mintable", 
        alias="s_realms",
        arguments=[
            "12345",  # name
            "12345",  # ticker
            admin,  # contract_owner
        ],
    )

    print(s_realms)
    resources = nre.deploy(
        "Resources_ERC1155_Mintable_Burnable", alias="resources",
        arguments=["1234", admin],
    )

    print(resources)
