
library(dplyr)
library(readr)
library(AzureStor)
library(AzureKeyVault)

# connect to kv
print("Connecting to key vault")

keyvault_uri <- "https://adf-iac-kv.vault.azure.net/"
vault <- key_vault(keyvault_uri)

access_key <- vault$secrets$get("ACCESSKEYSA")

# connect to blob
print("Connecting to blob container")

endpoint  <- storage_endpoint("https://adfiacsa.blob.core.windows.net/",
                   key = access_key)

container <- storage_container(endpoint, "input")

input_file_name <- "input_data.csv"
storage_download(container, "input/input_data.csv", input_file_name, overwrite=T)

df <- read_csv(input_file_name)
head(df)

# upload
print("Uploading output file")

output_file_name <- "output_data.csv"

write_csv(df, output_file_name)

storage_upload(
  container,
  src = output_file_name,
  dest = "output/output_data.csv"
)