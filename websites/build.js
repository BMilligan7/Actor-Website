const requestForm = document.querySelector('#website-request');
const conceptSection = document.querySelector('#concept-section');
const formStatus = document.querySelector('#form-status');
const submitButton = requestForm.querySelector('button[type="submit"]');
const conceptName = document.querySelector('#concept-name');
const mockWordmark = document.querySelector('#mock-wordmark');
const mockHeadline = document.querySelector('#mock-headline');
const mockDescription = document.querySelector('#mock-description');
const mockLink = document.querySelector('#mock-link');
const mockStatus = document.querySelector('#mock-status');
const mockAction = document.querySelector('#mock-action');

const storageKey = 'brandon-dean-build-concept';

function firstLink(rawLinks) {
  const candidate = rawLinks
    .split(/[\s,]+/)
    .find((link) => link.trim().length > 0);

  if (!candidate) return '';
  return /^(https?:)?\/\//i.test(candidate) ? candidate : `https://${candidate}`;
}

function updateConcept({ name, links, project }) {
  const displayName = name.trim() || 'your work';
  const siteGoal = project.trim() || 'A focused, expressive site built around the work people need to see.';
  const link = firstLink(links);

  conceptName.textContent = displayName;
  mockWordmark.textContent = displayName;
  mockHeadline.textContent = `${displayName} deserves a place to live.`;
  mockDescription.textContent = siteGoal;
  conceptSection.hidden = false;

  if (link) {
    mockLink.href = link;
    mockLink.hidden = false;
  } else {
    mockLink.hidden = true;
  }

  sessionStorage.setItem(storageKey, JSON.stringify({ name, links, project }));
  conceptSection.scrollIntoView({ behavior: 'smooth', block: 'start' });
}

function setMockMessage(message) {
  mockStatus.textContent = message;
}

document.querySelectorAll('[data-mock-section]').forEach((button) => {
  button.addEventListener('click', () => {
    const messages = {
      work: 'This could lead with the work that makes people stop scrolling.',
      story: 'This is where the person behind the work gets to feel real.',
      contact: 'A clean call to action can make it easy for the right people to reach out.'
    };
    setMockMessage(messages[button.dataset.mockSection]);
  });
});

mockAction.addEventListener('click', () => {
  setMockMessage('This button could become the main action you want visitors to take.');
});

requestForm.addEventListener('submit', async (event) => {
  event.preventDefault();

  const fields = new FormData(requestForm);
  const request = {
    name: fields.get('name').toString(),
    email: fields.get('email').toString(),
    links: fields.get('links').toString(),
    project: fields.get('project').toString()
  };
  fields.append('_replyto', request.email);

  updateConcept(request);
  submitButton.disabled = true;
  submitButton.textContent = 'Sending your request…';
  formStatus.classList.remove('is-error');
  formStatus.textContent = '';

  try {
    const response = await fetch('https://formsubmit.co/ajax/brandondmilligan@icloud.com', {
      method: 'POST',
      headers: { Accept: 'application/json' },
      body: fields
    });

    if (!response.ok) throw new Error('The request could not be sent.');
    formStatus.textContent = 'Your request is in. Your concept is ready below, and Brandon will follow up by email.';
    requestForm.reset();
  } catch (error) {
    const subject = encodeURIComponent('Website concept request');
    const body = encodeURIComponent(`Name: ${request.name}\nEmail: ${request.email}\nLinks: ${request.links}\nProject: ${request.project}`);
    formStatus.classList.add('is-error');
    formStatus.innerHTML = `Your concept is ready below. The email step needs another try—<a href="mailto:brandondmilligan@icloud.com?subject=${subject}&body=${body}">send this request directly by email</a>.`;
  } finally {
    submitButton.disabled = false;
    submitButton.innerHTML = 'Create my concept <span aria-hidden="true">↗</span>';
  }
});

try {
  const savedConcept = JSON.parse(sessionStorage.getItem(storageKey));
  if (savedConcept) updateConcept(savedConcept);
} catch {
  sessionStorage.removeItem(storageKey);
}
