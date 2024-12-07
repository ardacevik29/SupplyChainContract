// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/SupplyChain.sol";

contract SupplyChainCreateProductTest is Test {
    SupplyChain public supplyChain;
    address public owner = address(1);
    address public nonOwner = address(2);

    // Define custom errors used in the contract
    error SupplyChain__LocationCantBeEmpty();
    error SupplyChain__ProducedDateMustBeValid();
    error SupplyChain__ExpirationDateMustBeGreaterThanProductionDate();
    error OwnableUnauthorizedAccount(address account);
    
      event Tracking(
        uint256 indexed productId,
        string location,
       SupplyChain.ProductStatus status,
        uint256 producedDate,
        uint256 expirationDate
    );
    function setUp() public {
        // Deploy the contract as the owner
        vm.prank(owner);
        supplyChain = new SupplyChain();
    }

    function testCreateProductSuccess() public {
        vm.prank(owner);

        string memory location = "New York";
        uint256 producedDate = block.timestamp;
        uint256 expirationDate = block.timestamp + 30 days;

        // Expect an emit of the Tracking event
        vm.expectEmit(true, true, true, true);
        emit SupplyChain.Tracking(1, location, SupplyChain.ProductStatus.Produce, producedDate, expirationDate);

        // Call createProduct
        supplyChain.createProduct(location, producedDate, expirationDate);

        // Verify product count
        uint256 count = supplyChain.getProductCount();
        assertEq(count, 1);

        // Retrieve product details
        SupplyChain.ProductDetails memory product = supplyChain.getProductDetails(1);

        // Assertions
        assertEq(product.id, 1);
        assertEq(product.location, location);
        assertEq(uint256(product.status), uint256(SupplyChain.ProductStatus.Produce));
        assertEq(product.producedDate, producedDate);
        assertEq(product.expirationDate, expirationDate);
    }

    function testCreateProductRevertEmptyLocation() public {
        vm.prank(owner);

        string memory location = "";
        uint256 producedDate = block.timestamp;
        uint256 expirationDate = block.timestamp + 30 days;

        // Expect revert due to empty location
        vm.expectRevert(SupplyChain__LocationCantBeEmpty.selector);

        // Call createProduct
        supplyChain.createProduct(location, producedDate, expirationDate);
    }

    function testCreateProductRevertInvalidProducedDate() public {
        vm.prank(owner);

        string memory location = "Los Angeles";
        uint256 producedDate = 0;
        uint256 expirationDate = block.timestamp + 30 days;

        // Expect revert due to invalid produced date
        vm.expectRevert(SupplyChain__ProducedDateMustBeValid.selector);

        // Call createProduct
        supplyChain.createProduct(location, producedDate, expirationDate);
    }

    function testCreateProductRevertInvalidExpirationDate() public {
        vm.prank(owner);

        string memory location = "Chicago";
        uint256 producedDate = block.timestamp;
        uint256 expirationDate = producedDate; // Not greater than produced date

        // Expect revert due to expiration date not greater than produced date
        vm.expectRevert(SupplyChain__ExpirationDateMustBeGreaterThanProductionDate.selector);

        // Call createProduct
        supplyChain.createProduct(location, producedDate, expirationDate);
    }

    function testCreateProductRevertNonOwner() public {
        vm.prank(nonOwner);

        string memory location = "San Francisco";
        uint256 producedDate = block.timestamp;
        uint256 expirationDate = block.timestamp + 30 days;

        // Expect revert due to onlyOwner modifier
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, nonOwner));

        // Call createProduct
        supplyChain.createProduct(location, producedDate, expirationDate);
    }

function testTrackingEventIsEmitted() public {
    // Arrange: Ürün oluşturmak için gerekli veriler
    string memory location = "Factory";
    uint256 producedDate = block.timestamp;
    uint256 expirationDate = block.timestamp + 30 days;

    // `Tracking` eventini bekliyoruz
    vm.expectEmit(true, false, false, true); // productId indexed olduğu için true, diğerleri indexed değil.
    emit SupplyChain.Tracking(1, location, SupplyChain.ProductStatus.Produce, producedDate, expirationDate);

    // Act: Ürün oluşturuluyor
    vm.prank(owner); // İşlemi `owner` rolünde yapıyoruz.
    supplyChain.createProduct(location, producedDate, expirationDate);

    // Assert: Ürün detaylarını kontrol edelim
    SupplyChain.ProductDetails memory product = supplyChain.getProductDetails(1);
    assertEq(product.id, 1);
    assertEq(product.location, location);
    assertEq(uint256(product.status), uint256(SupplyChain.ProductStatus.Produce));
    assertEq(product.producedDate, producedDate);
    assertEq(product.expirationDate, expirationDate);
}

}
