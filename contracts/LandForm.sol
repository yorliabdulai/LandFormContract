// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract LandForm {
    struct Project {
        uint256 id;
        string title;
        string location;
        uint256 pricePerShare;
        uint256 totalShares;
        uint256 availableShares;
        string imageId; // Changed to imageId - can be IPFS hash or other short identifier
        string description;
        bool isActive;
    }

    address public owner;
    address public pendingOwner;
    uint256 public nextId;
    mapping(uint256 => Project) public projects;
    
    // Track active project IDs in a more gas-efficient way
    uint256[] private projectIds;

    event ProjectAdded(uint256 indexed id, string title);
    event ProjectUpdated(uint256 indexed id, string field);
    event ProjectStatusChanged(uint256 indexed id, bool isActive);
    event Invested(uint256 indexed projectId, address investor, uint256 shares);
    event OwnershipTransferStarted(address indexed currentOwner, address indexed newOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized: Only contract owner can perform this action");
        _;
    }

    modifier validProject(uint256 projectId) {
        require(projectId < nextId, "Invalid project ID");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addProject(
        string calldata _title,
        string calldata _location,
        uint256 _pricePerShare,
        uint256 _totalShares,
        string calldata _imageId,
        string calldata _description
    ) external onlyOwner {
        // Input validation with descriptive error messages
        require(bytes(_title).length > 0, "Title cannot be empty");
        require(bytes(_location).length > 0, "Location cannot be empty");
        require(_pricePerShare > 0, "Price per share must be greater than 0");
        require(_totalShares > 0, "Total shares must be greater than 0");
        require(bytes(_imageId).length <= 100, "Image identifier too long");
        
        uint256 currentId = nextId;
        projects[currentId] = Project({
            id: currentId,
            title: _title,
            location: _location,
            pricePerShare: _pricePerShare,
            totalShares: _totalShares,
            availableShares: _totalShares,
            imageId: _imageId,
            description: _description,
            isActive: true
        });
        
        projectIds.push(currentId);
        emit ProjectAdded(currentId, _title);
        nextId = currentId + 1;
    }

    // Get a single project by ID
    function getProject(uint256 projectId) external view validProject(projectId) returns (Project memory) {
        return projects[projectId];
    }
    
    // Get total number of projects
    function getProjectCount() external view returns (uint256) {
        return projectIds.length;
    }

    function getAllProjects() external view returns (Project[] memory) {
        uint256 count = projectIds.length;
        Project[] memory result = new Project[](count);
        
        for (uint256 i = 0; i < count; i++) {
            result[i] = projects[projectIds[i]];
        }
        
        return result;
    }

    function getActiveProjects() external view returns (Project[] memory) {
        uint256 count = projectIds.length;
        
        // First count active projects
        uint256 activeCount = 0;
        for (uint256 i = 0; i < count; i++) {
            if (projects[projectIds[i]].isActive) {
                activeCount++;
            }
        }
        
        // Then populate the array
        Project[] memory activeProjects = new Project[](activeCount);
        uint256 index = 0;
        for (uint256 i = 0; i < count; i++) {
            uint256 projectId = projectIds[i];
            if (projects[projectId].isActive) {
                activeProjects[index] = projects[projectId];
                index++;
            }
        }
        
        return activeProjects;
    }

    function investInProject(uint256 projectId, uint256 shares) external payable validProject(projectId) {
        Project storage project = projects[projectId];
        require(project.isActive, "Project is inactive");
        require(shares > 0, "Must invest in at least one share");
        require(shares <= project.availableShares, "Not enough shares available");
        
        uint256 cost = shares * project.pricePerShare;
        require(msg.value == cost, "Incorrect payment amount");

        project.availableShares -= shares;
        emit Invested(projectId, msg.sender, shares);
    }

    // --- Admin Controls ---

    function setProjectStatus(uint256 projectId, bool _isActive) external onlyOwner validProject(projectId) {
        projects[projectId].isActive = _isActive;
        emit ProjectStatusChanged(projectId, _isActive);
    }

    function updateProjectShares(uint256 projectId, uint256 newTotalShares) external onlyOwner validProject(projectId) {
        Project storage p = projects[projectId];
        uint256 soldShares = p.totalShares - p.availableShares;
        require(newTotalShares >= soldShares, "Cannot reduce below sold shares");

        p.availableShares += (newTotalShares - p.totalShares);
        p.totalShares = newTotalShares;
        
        emit ProjectUpdated(projectId, "shares");
    }

    function updateProjectMetadata(
        uint256 projectId,
        string calldata _title,
        string calldata _location,
        uint256 _pricePerShare,
        string calldata _imageId,
        string calldata _description
    ) external onlyOwner validProject(projectId) {
        // Input validation
        require(bytes(_title).length > 0, "Title cannot be empty");
        require(bytes(_location).length > 0, "Location cannot be empty");
        require(_pricePerShare > 0, "Price per share must be greater than 0");
        require(bytes(_imageId).length <= 100, "Image identifier too long");
        
        Project storage p = projects[projectId];
        p.title = _title;
        p.location = _location;
        p.pricePerShare = _pricePerShare;
        p.imageId = _imageId;
        p.description = _description;
        
        emit ProjectUpdated(projectId, "metadata");
    }

    // Function to delete a project - should be used carefully
    function deleteProject(uint256 projectId) external onlyOwner validProject(projectId) {
        // Find the index of the project in projectIds array
        uint256 indexToDelete = type(uint256).max;
        for (uint256 i = 0; i < projectIds.length; i++) {
            if (projectIds[i] == projectId) {
                indexToDelete = i;
                break;
            }
        }
        
        require(indexToDelete != type(uint256).max, "Project not found in projectIds");
        
        // Move the last element to the deleted position
        if (indexToDelete != projectIds.length - 1) {
            projectIds[indexToDelete] = projectIds[projectIds.length - 1];
        }
        
        // Remove the last element
        projectIds.pop();
        
        // Delete the project mapping
        delete projects[projectId];
        
        emit ProjectUpdated(projectId, "deleted");
    }

    // --- Ownership Transfer Logic ---

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid address: Cannot transfer to zero address");
        pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner, newOwner);
    }

    function acceptOwnership() external {
        require(msg.sender == pendingOwner, "Not pending owner");
        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }

    // --- Withdraw function ---
    
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        
        (bool success, ) = owner.call{value: balance}("");
        require(success, "Transfer failed");
    }
}