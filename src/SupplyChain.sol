// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract SupplyChain is Ownable {

    error SupplyChain__LocationCantBeEmpty();
    error SupplyChain__ProducedDateMustBeValid();
    error SupplyChain__ExpirationDateMustBeGreaterThanProductionDate();
    error SupplyChain__ProductDoesNotExist();
    error SupplyChain__InvalidStatusTransition();
    
    enum ProductStatus {
        Produce,
        InWarehouse,
        Delivered
    }


    struct ProductDetails {
        uint256 id;
        string location;
        ProductStatus status;
        uint256 producedDate;
        uint256 expirationDate;
    }


    uint256 private productCount;
    mapping(uint256 => ProductDetails) private products;
    uint256[] private productIds;
    mapping(uint256 => uint256) private productIdToIndex;
    address immutable private i_owner;

    event Tracking(
        uint256 indexed productId,
        string location,
        ProductStatus status,
        uint256 producedDate,
        uint256 expirationDate
    );
    event ProductStatusUpdated(
        uint256 indexed productId,
        ProductStatus newStatus,
        string newLocation
    );
    event ProductDeleted(uint256 indexed productId);

    constructor () Ownable(msg.sender) {
      i_owner = msg.sender;
    }
    function createProduct(
        string memory _location,
        uint256 _producedDate,
        uint256 _expirationDate
    ) external onlyOwner {
        if (bytes(_location).length == 0) revert SupplyChain__LocationCantBeEmpty();
        if (_producedDate == 0) revert SupplyChain__ProducedDateMustBeValid();
        if (_expirationDate <= _producedDate) revert SupplyChain__ExpirationDateMustBeGreaterThanProductionDate();

        productCount += 1;
        uint256 newProductId = productCount;

        ProductDetails storage newProduct = products[newProductId];
        newProduct.id = newProductId;
        newProduct.location = _location;
        newProduct.status = ProductStatus.Produce;
        newProduct.producedDate = _producedDate;
        newProduct.expirationDate = _expirationDate;

        productIds.push(newProductId);
        productIdToIndex[newProductId] = productIds.length - 1;

        emit Tracking(newProductId, _location, ProductStatus.Produce, _producedDate, _expirationDate);
    }

    function updateProductStatus(
        uint256 _productId,
        ProductStatus _newStatus,
        string memory _newLocation
    ) external onlyOwner {
        ProductDetails storage product = products[_productId];
        if (product.id == 0) revert SupplyChain__ProductDoesNotExist();
        if (!_isValidStatusTransition(product.status, _newStatus)) revert SupplyChain__InvalidStatusTransition();
        if (bytes(_newLocation).length == 0) revert SupplyChain__LocationCantBeEmpty();

        product.status = _newStatus;
        product.location = _newLocation;

        emit Tracking(_productId, _newLocation, _newStatus, product.producedDate, product.expirationDate);
    }

    function deleteProduct(uint256 _productId) external onlyOwner {
        ProductDetails storage product = products[_productId];
        if (product.id == 0) revert SupplyChain__ProductDoesNotExist();

        // Remove from mapping
        delete products[_productId];

        // Remove from array and mapping
        uint256 index = productIdToIndex[_productId];
        uint256 lastIndex = productIds.length - 1;
        uint256 lastProductId = productIds[lastIndex];

        if (index != lastIndex) {
            productIds[index] = lastProductId;
            productIdToIndex[lastProductId] = index;
        }

        productIds.pop();
        delete productIdToIndex[_productId];

        productCount -= 1;
        emit ProductDeleted(_productId);
    }

    function getProductDetails(uint256 _productId) external view returns (ProductDetails memory) {
        ProductDetails memory product = products[_productId];
        if (product.id == 0) revert SupplyChain__ProductDoesNotExist();
        return product;
    }

    function getAllProductIds() external view returns (uint256[] memory) {
        return productIds;
    }

    function getProductCount() external view returns (uint256) {
        return productCount;
    }

    function getProductStatus(uint256 _productId) external view returns (ProductStatus) {
        ProductDetails memory product = products[_productId];
        if (product.id == 0) revert SupplyChain__ProductDoesNotExist();
        return product.status;
    }

    function getProductLocation(uint256 _productId) external view returns (string memory) {
        ProductDetails memory product = products[_productId];
        if (product.id == 0) revert SupplyChain__ProductDoesNotExist();
        return product.location;
    }

    function getProductProducedDate(uint256 _productId) external view returns (uint256) {
        ProductDetails memory product = products[_productId];
        if (product.id == 0) revert SupplyChain__ProductDoesNotExist();
        return product.producedDate;
    }

    function getProductExpirationDate(uint256 _productId) external view returns (uint256) {
        ProductDetails memory product = products[_productId];
        if (product.id == 0) revert SupplyChain__ProductDoesNotExist();
        return product.expirationDate;
    }

    function _isValidStatusTransition(ProductStatus _currentStatus, ProductStatus _newStatus) internal pure returns (bool) {
        if (_currentStatus == ProductStatus.Produce && _newStatus == ProductStatus.InWarehouse) return true;
        if (_currentStatus == ProductStatus.InWarehouse && _newStatus == ProductStatus.Delivered) return true;
        return false;
    }
    function getOwner() external view returns (address) {
        return i_owner;
    }
}
