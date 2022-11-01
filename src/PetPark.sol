//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract PetPark {

    address immutable owner;

    enum AnimalType {
        None,
        Fish,
        Cat,
        Dog,
        Rabbit,
        Parrot
    }

    enum Gender {
        Male,
        Female
    }

    struct Borrower {
        Gender gender;
        uint8 age;
        AnimalType animalType;
    }

    mapping(AnimalType => uint) totalPetCount;
    mapping(AnimalType => uint) availablePetCount;
    mapping(address => Borrower) borrowers;

    event Added(AnimalType animalType, uint256 count);
    event Borrowed(AnimalType animalType);
    event Returned(AnimalType animalType);

    constructor() {
        owner = msg.sender;    
    }

    function add(AnimalType _animalType, uint256 _count) public {
        require(msg.sender == owner, "Only owner can add pets");
        require(_animalType != AnimalType.None, "Invalid animal");

        totalPetCount[_animalType] += _count;
        availablePetCount[_animalType] += _count;
        emit Added(_animalType, _count);
    }

    function borrow(uint8 _age, Gender _gender, AnimalType _animalType) public {
        require(_age > 0, "Age must be non-zero");
        require(_animalType != AnimalType.None, "Invalid animal type");
        
        Borrower memory borrower = borrowers[msg.sender];
        if (borrower.age > 0) {
            if (borrower.age != _age) {
                revert("Invalid Age");
            }
            if (borrower.gender != _gender) {
                revert("Invalid Gender");
            }
            revert("Already adopted a pet");
        }

        if (availablePetCount[_animalType] == 0) {
            revert("Selected animal not available");    
        }

        if (_gender == Gender.Male && _animalType != AnimalType.Dog && _animalType != AnimalType.Fish) {
            revert("Invalid animal for men");
        }

        if (_gender == Gender.Female && _animalType == AnimalType.Cat && _age < 40) {
            revert("Invalid animal for women under 40");
        }

        borrowers[msg.sender] = Borrower(_gender, _age, _animalType);
        availablePetCount[_animalType]--;

        emit Borrowed(_animalType);
    }

    function giveBackAnimal() public {
        Borrower memory borrower = borrowers[msg.sender];
        require(borrower.age > 0, "No borrowed pets");

        availablePetCount[borrower.animalType]++;
        emit Returned(borrower.animalType);
    }

    function animalCounts(AnimalType _animalType) public view returns (uint) {
        return availablePetCount[_animalType];
    }
}