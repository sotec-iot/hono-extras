package function

import (
	"context"
	"encoding/base64"
	"fmt"
	"os"

	"github.com/sendgrid/sendgrid-go"
	"github.com/sendgrid/sendgrid-go/helpers/mail"
)

type PubSubMessage struct {
	Data       string            `json:"data"`
	Attributes map[string]string `json:"attributes"`
}

func SendEmail(ctx context.Context, m PubSubMessage) error {
	fmt.Println("Received pubsub")

	decodedByte, err := base64.StdEncoding.DecodeString(m.Data)
	if err != nil {
		return fmt.Errorf("error when decoding message data")
	}

	messageContent := fmt.Sprintf(
		"Hello,\n\n"+
			"following event occurred for cluster '%s' in project '%s'.\n\n"+
			"%s\n\n",
		m.Attributes["cluster_name"], m.Attributes["project_id"], string(decodedByte),
	)

	recipientMail := os.Getenv("MAIL")
	if recipientMail == "" {
		return fmt.Errorf("MAIL environment variable is not set")
	}
	sendgridApiKey := os.Getenv("SENDGRID_API_KEY")
	if sendgridApiKey == "" {
		return fmt.Errorf("SENDGRID_API_KEY environment variable is not set")
	}
	sendgridDomain := os.Getenv("SENDGRID_DOMAIN")
	if sendgridDomain == "" {
		return fmt.Errorf("SENDGRID_DOMAIN environment variable is not set")
	}
	projectId := os.Getenv("PROJECT_ID")
	if projectId == "" {
		return fmt.Errorf("PROJECT_ID environment variable is not set")
	}

	from := mail.NewEmail("GKE Event Notifier", projectId+"@"+sendgridDomain)
	to := mail.NewEmail("Recipient", recipientMail)
	subject := fmt.Sprintf("GKE event in %s for cluster %s", projectId, m.Attributes["cluster_name"])
	plainTextContent := messageContent
	htmlContent := fmt.Sprintf("<strong>%s</strong>", messageContent)
	message := mail.NewSingleEmail(from, subject, to, plainTextContent, htmlContent)

	client := sendgrid.NewSendClient(sendgridApiKey)
	response, err := client.Send(message)
	if err != nil {
		return fmt.Errorf("failed to send email: %v", err)
	}
	fmt.Printf("%d", response.StatusCode)
	fmt.Printf("%s", response.Body)

	return nil
}
