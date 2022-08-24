

# SPDX-License-Identifier: MIT
# OpenZeppelin Contracts for Cairo v0.2.0 (token/erc721/interfaces/IERC721_Metadata.cairo)

%lang starknet

from starkware.cairo.common.uint256 import Uint256

from contracts.token.ERC721.interfaces.IERC721 import IERC721

@contract_interface
namespace IERC721_Metadata:
    func name() -> (name: felt):
    end

    func symbol() -> (symbol: felt):
    end

    func tokenURI(tokenId: Uint256) -> (tokenURI: felt):
    end
end