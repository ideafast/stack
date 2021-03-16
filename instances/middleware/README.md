## MongoDB Authentication

Authentication is disabled in mongodb by default, and will need to be setup to access the db remotely. To do that: 

1. Remove `command: [--auth]` from the `docker-compose.yml`.  
2. Run `docker compose up -d` to see the changes. 
3. Enter the docker container: `docker exec -it mongo bash`
4. Run `mongo` from the command line and create two users as follows:

```bash
use admin
db.createUser(
    {
        user: "ADMIN_USER",
        pwd: "ROOT_PASSWORD",
        roles:["root"]
    }
);

use dtransfer
db.createUser(
    {
        user: "DT_USER",
        pwd: "DT_PASSWORD",
        roles:[
            {
                role: "readWrite",
                db: "dtransfer"
            }
        ]
    }
);
```

**Note**: change `user` and `pwd` with desired secrets.