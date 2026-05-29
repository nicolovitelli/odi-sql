## [Scenarios](./scenarios.sql)
All available scenarios in the repository.

---

## [Scenario Task](./scenario_task.sql)
All tasks generated inside each scenario.

---

## [Mappings](./mappings.sql)
All mappings available in the repository. This extraction also shows several properties set in the physical layer:
* `cleanup_on_error` => Remove Temporary Objects on Error
* `is_concurrent` => Use Unique Temporary Object Names
* `is_frozen` => Is Frozen

---

## [Packages](./packages.sql)
All packages available in the repository.

---

## [Procedures](./procedures.sql)
All procedures available in the repository.

---

## [Procedure Steps](./procedure_steps.sql)
All procedure steps for each procedure available in ODI.

---

## [Procedure Variables](./procedure_variables.sql)
extracts procedures along with the variables used within them.
the distinct keyword is used to remove duplicate entries of the same variable when it appears multiple times within the same procedure.

---

## [Variables](./variables.sql)
All variables available in the repository.

---

## [Sequences](./sequences.sql)
All sequences available in the repository.

---

## [Projects](./projects.sql)
All projects available in the repository.

---

## [Folders](./folders.sql)
All folders available in the repository.

---

## [Models](./models.sql)
All models available in the repository.

---

## [Datastores](./datastores.sql)
All datastores available in the repository.

---

## [Datastore Columns](./datastore_columns.sql)
All datastore columns available in the repository.

---

## [Load Plans](./load_plans.sql)
All load plans available in the repository.

---

## [Scenario Load Plan](./scenario_load_plan.sql)
extracts load plans along with the scenarios used within them.
also indicates whether each scenario is currently enabled.

---

## [Load Plan Hierarchy](./load_plan_hierarchy.sql)
The structural hierarchy of steps (Serial, Parallel, Run Scenario) within load plans.