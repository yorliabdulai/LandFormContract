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
        string imageHash; // IPFS hash instead of full URL
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
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier validProject(uint256 projectId) {
        require(projectId < nextId, "Invalid project ID");
        _;
    }

    constructor() {
        owner = msg.sender;
        // No need to initialize nextId as it defaults to 0
    }

    function addProject(
        string calldata _title,
        string calldata _location,
        uint256 _pricePerShare,
        uint256 _totalShares,
        string calldata _imageHash,
        string calldata _description
    ) external onlyOwner {
        uint256 currentId = nextId;
        
        projects[currentId] = Project({
            id: currentId,
            title: _title,
            location: _location,
            pricePerShare: _pricePerShare,
            totalShares: _totalShares,
            availableShares: _totalShares,
            imageHash: _imageHash,
            description: _description,
            isActive: true
        });
        
        projectIds.push(currentId);
        emit ProjectAdded(currentId, _title);
        nextId = currentId + 1; // More gas efficient than nextId++
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
        require(shares <= project.availableShares, "Not enough shares");
        
        uint256 cost = shares * project.pricePerShare;
        require(msg.value == cost, "Incorrect payment");

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
        string calldata _imageHash,
        string calldata _description
    ) external onlyOwner validProject(projectId) {
        Project storage p = projects[projectId];
        p.title = _title;
        p.location = _location;
        p.pricePerShare = _pricePerShare;
        p.imageHash = _imageHash;
        p.description = _description;
        
        emit ProjectUpdated(projectId, "metadata");
    }

    // --- Ownership Transfer Logic ---

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid address");
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
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }
}