# Warehouse app

<!-- Table of Contents -->
# :notebook_with_decorative_cover: Table of Contents

- [About the Project](#star2-about-the-project)
  * [Key Features](#star-key-features)
  * [Screenshots](#camera-screenshots)
  * [Tech Stack](#space_invader-tech-stack)
- [Roadmap](#compass-roadmap)

<!-- About the Project -->
## :star2: About the Project

The presented application is designed for tracking data related to the condition of owned bicycles, as well as the dates and details of their maintenance. It operates based on data retrieved from the Strava API. The idea for this application was born out of a simple request from a friend who said, "Write something that keeps track of the kilometers since the last marked date." Since then, it has become clear that he owns more than one bicycle, and each bicycle has more than one chain. It is necessary to associate each "ride" from Strava with a specific chain and bicycle based on the last change date of the chain. Additionally, the application allows users to add notes about other maintenance work along with relevant dates.

<!-- Key Features -->
### :star: Key Features
- Bicycle Data Tracking: Easily track the condition of multiple bicycles, including details about each bike's specifications.

- Chain Management: Associate each ride recorded on Strava with a specific chain and bicycle, all based on the last change date of the chain.

- Maintenance Notes: Keep a record of maintenance activities with accompanying dates, ensuring a comprehensive maintenance history.

- Strava Integration: Seamlessly integrate with the Strava API to retrieve and link ride data.

- User-Friendly Interface: The application provides an intuitive user interface for easy navigation and data entry.

<!-- Screenshots -->
### :camera: Screenshots
<div align="center"> 
  <img src="https://github.com/BarrYPL/warehouse_app/blob/master/public/images/ss1.png?raw=true" alt="screenshot" />
</div>

<div align="center"> 
  <img src="https://github.com/BarrYPL/warehouse_app/blob/master/public/images/ss2.png?raw=true" alt="screenshot" />
</div>

<div align="center"> 
  <img src="https://github.com/BarrYPL/warehouse_app/blob/master/public/images/ss3.png?raw=true" alt="screenshot" />
</div>

<div align="center"> 
  <img src="https://github.com/BarrYPL/warehouse_app/blob/master/public/images/ss4.png?raw=true" alt="screenshot" />
</div>

<div align="center"> 
  <img src="https://github.com/BarrYPL/warehouse_app/blob/master/public/images/ss5.jpg?raw=true" alt="screenshot" />
</div>

<!-- TechStack -->
### :space_invader: Tech Stack

  <summary>Server</summary>
  <details>
  <ul>
    <li><a href="https://www.ruby-lang.org/">Ruby</a></li>
    <li><a href="https://sinatrarb.com">Sinatra framework</a></li>
    <li><a href="https://www.sqlite.org/index.html">SQLite</a></li>    
    <li><a href="https://en.wikipedia.org/wiki/HTML">HTML</a></li>
    <li><a href="https://en.wikipedia.org/wiki/CSS">CSS</a></li>
    <li><a href="https://en.wikipedia.org/wiki/JavaScript">JavaScript</a></li>
  </ul>
</details>

## :compass: Roadmap

* [ ] Migrate app to RoR
