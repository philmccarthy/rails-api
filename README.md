<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Thanks again! Now go create something AMAZING! :D
-->



<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
[![LinkedIn][linkedin-shield]][linkedin-url]


<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
      </ul>
    </li>
    <li><a href="#rest-endpoints">ReST Endpoints</a></li>
    <li><a href="#non-rest-endpoints">Non-ReST Endpoints</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

This Rails backend-only API was built in 6 days while I was in Mod 3 of [Turing School's](https://turing.io) Backend Engineering program.

Areas of exploration and learning on this project included:

* Expose an API
* Use serializers to format JSON responses
* Test API exposure with RSpec and Postman
* Compose advanced ActiveRecord queries to analyze information stored in PostgreSQL database
* Write SQL statements without the assistance of an ORM


### Built With

* [Ruby on Rails](https://rubyonrails.org/)
* [PostgreSQL](https://www.postgresql.org/)
* [Postman](https://www.postman.com/)

<!-- GETTING STARTED -->
## Getting Started

1. Clone this repo
2. Install gem packages: `bundle install`
3. Setup the database. A pgdump is included in `./db` to seed the database

    `rails db:{create,migrate,seed}`

### Prerequisites

* Ruby 2.5.3
* Rails 5.2

<!-- USAGE EXAMPLES -->
## ReST Endpoints

### Get All Merchants

Optional Parameters: `?per_page` (defaults to 20 results) and `?page`.

  ```
  GET /api/v1/merchants?per_page=x&page=x
  ```

### Get One Merchant

  ````
  GET /api/v1/merchants/:id
  ````

### Get a Merchant's Items

  ```
  GET /api/v1/merchants/:id/items
  ```


### Get All Items

Optional Parameters: `?per_page` (defaults to 20 results) and `?page`.

```
GET /api/v1/items?per_page=x&page=x
```


### Get One Item

```
GET /api/v1/items/:id
```


### Get an Item's Merchant

```
GET /api/v1/items/:id/merchant
```


### Update One Item

```
PATCH /api/v1/items/:id
```

Item attributes:

  ```json
  {
    "name": "value1",
    "description": "value2",
    "unit_price": 100.99,
    "merchant_id": 14
  }
  ```


### Create One Item

  ```
  POST /api/v1/items/
  ```

Create item body format:

  ```json
  {
    "name": "value1",
    "description": "value2",
    "unit_price": 100.99,
    "merchant_id": 14
  }
  ```

### Delete One Item

```
DELETE /api/v1/items/:id
```

## Non-ReST Endpoints

### Find All Merchants by Fragment

Required Parameter: `?name`.

  ```
  GET /api/v1/merchants/find_all?name=x
  ```

### Find One Item by Fragment

Parameter(s): `?name`, `min_price` and `max_price`.

- At least one parameter is required
- Name _cannot_ be combined with either/both price parameters
- Minimum price and maximum price _can_ be used alone or together to query a price range

### Get Merchants with Most Revenue

Required Parameter: `?quantity` is required

```
GET /api/v1/revenue/merchants?quantity=x
```

### Get Merchants who Sold Most Items

Optional Parameter: `?quantity` is _not_ required for this query. Defaults to 5 results.

```
GET /api/v1/merchants/most_items?quantity=
```

### Get Revenue of a Single Merchant

```
GET /api/v1/revenue/merchants/:id
```

### Get Items with Most Revenue

Parameter: `quantity?` is _not_ required. Defaults to 10 results.

```
GET /api/v1/items/revenue?quantity=x
```


<!-- CONTACT -->
## Contact

Phil McCarthy - [LinkedIn](https://linkedin.com/in/pjmcc)

Project Link: [https://github.com/your_username/repo_name](https://github.com/your_username/repo_name)

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/pjmcc